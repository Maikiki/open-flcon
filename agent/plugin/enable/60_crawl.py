#!/bin/env python
# encoding: utf-8

import urllib2
import json
import socket
import time


root_url = "http://"+socket.gethostbyname(socket.gethostname())
#root_url = "http://192.168.55.10"
# 节点、端口
node_list = ['NameNode',
             'DataNode',
             'HMaster',
             'HRegionServer',
             'NodeManager',
             'ResourceManager']

port_list = ('50070', '50075', '60010', '60030', '8042', '8088')

#爬取fsdataset

fsdataset = ""
temp = root_url + ':' + '50075' + '/jmx?' + 'qry=Hadoop:*'
try:
    temp_dataset = json.loads(urllib2.urlopen(temp).read())['beans']
except urllib2.URLError:
    pass
else:
    for i in range(len(temp_dataset)):
        if 'FSDatasetState' in temp_dataset[i]['name'] :
            fsdataset = temp_dataset[i]['name']

#print fsdataset


# JMX查询
NameNode_name_list = ['java.lang:type=Memory',
                      'Hadoop:service=NameNode,name=RpcActivityForPort8020',
                      'Hadoop:service=NameNode,name=FSNamesystemState',
                      'java.lang:type=OperatingSystem']

DataNode_name_list = ['java.lang:type=Memory',
                      fsdataset,
                      'Hadoop:service=DataNode,name=RpcActivityForPort8010',
                      'java.lang:type=OperatingSystem',
                      'Hadoop:service=DataNode,name=DataNodeActivity-' + socket.gethostname() + '-50010'
                      ]
#print DataNode_name_list[1]
HMaster_name_list = ['java.lang:type=Memory',
                     'java.lang:type=OperatingSystem',
                     'Hadoop:service=HBase,name=IPC,sub=IPC'
                     ]

HRegionServer_name_list = ['java.lang:type=Memory',
                           'java.lang:type=OperatingSystem',
                           'Hadoop:service=HBase,name=RegionServer,sub=Server',
                           'Hadoop:service=HBase,name=IPC,sub=IPC'
                           ]

NodeManager_name_list = ['java.lang:type=Memory',
                         'java.lang:type=OperatingSystem',
                         'Hadoop:service=NodeManager,name=RpcActivityForPort45454',
                         'Hadoop:service=NodeManager,name=NodeManagerMetrics',
                         ]

ResourceManager_name_list = ['java.lang:type=Memory',
                             'java.lang:type=OperatingSystem',
                             'Hadoop:service=ResourceManager,name=RpcActivityForPort8032',
                             'Hadoop:service=ResourceManager,name=ClusterMetrics',
                             'Hadoop:service=ResourceManager,name=QueueMetrics,q0=root'
                             ]

#metric列表
NameNode_metric_list = [['HeapMemoryUsage',
                         'NonHeapMemoryUsage'
                         ],
                        ['tag.port',
                         'RpcProcessingTimeNumOps',
                         'RpcProcessingTimeAvgTime',
                         'RpcQueueTimeAvgTime',
                         'NumOpenConnections'
                         ],
                        ['CapacityTotal',
                         'CapacityUsed',
                         'CapacityRemaining',
                         'BlocksTotal',
                         'FSState'
                         ],
                        ['MaxFileDescriptorCount',
                         'OpenFileDescriptorCount'
                         ]
                        ]

DataNode_metric_list = [['HeapMemoryUsage',
                         'NonHeapMemoryUsage'
                         ],
                        ['DfsUsed',
                         'Capacity',
                         'Remaining'
                         ],
                        ['tag.port',
                         'RpcProcessingTimeNumOps',
                         'RpcProcessingTimeAvgTime',
                         'RpcQueueTimeAvgTime',
                         'NumOpenConnections'
                         ],
                        ['MaxFileDescriptorCount',
                         'OpenFileDescriptorCount'
                         ],
                        ['WriteBlockOpAvgTime'
                         ]
                        ]

HMaster_metric_list = [['HeapMemoryUsage',
                        'NonHeapMemoryUsage'
                        ],
                       ['MaxFileDescriptorCount',
                        'OpenFileDescriptorCount'
                        ],
                       ['QueueCallTime_99th_percentile',
                        'ProcessCallTime_99th_percentile'
                        ]
                       ]

HRegionServer_metric_list = [['HeapMemoryUsage',
                              'NonHeapMemoryUsage'
                              ],
                             ['MaxFileDescriptorCount',
                              'OpenFileDescriptorCount'
                              ],
                             ['regionCount',
                              'storeCount',
                              'memStoreSize',
                              'storeFileSize',
                              'readRequestCount',
                              'writeRequestCount',
                              'compactionQueueLength',
                              'flushQueueLength',
                              'blockCacheFreeSize',
                              'blockCacheSize',
                              'blockCountHitPercent',
                              'Append_99th_percentile',
                              'Mutate_99th_percentile',
                              # 'FlushTime_99th_percentile',
                              'Get_99th_percentile',
                              # 'SplitTime_99th_percentile'
                              ],
                             ['QueueCallTime_99th_percentile',
                              'ProcessCallTime_99th_percentile'
                              ]
                             ]

NodeManager_metric_list = [['HeapMemoryUsage',
                            'NonHeapMemoryUsage'
                            ],
                           #['LastGcInfo'
                           #],
                           ['MaxFileDescriptorCount',
                            'OpenFileDescriptorCount'
                            ],
                           ['tag.port',
                            'RpcProcessingTimeNumOps',
                            'RpcProcessingTimeAvgTime',
                            'RpcQueueTimeAvgTime',
                            'NumOpenConnections'
                            ],
                           ['AllocatedGB',
                            'AvailableGB',
                            'AllocatedVCores',
                            'AvailableVCores'
                            ]
                           ]

ResourceManager_metric_list = [['HeapMemoryUsage',
                                'NonHeapMemoryUsage'
                                ],
                               #['LastGcInfo'
                               #],
                               ['MaxFileDescriptorCount',
                                'OpenFileDescriptorCount'
                                ],
                               ['tag.port',
                                'RpcProcessingTimeNumOps',
                                'RpcProcessingTimeAvgTime',
                                'RpcQueueTimeAvgTime',
                                'NumOpenConnections'
                                ],
                               ['NumActiveNMs',
                                'NumDecommissionedNMs',
                                'NumLostNMs'
                                ],
                               ['tag.Queue',
                                'AppsRunning',
                                'AppsPending',
                                'AppsFailed',
                                'AllocatedMB',
                                'AllocatedVCores',
                                'AvailableMB',
                                'AvailableVCores',
                                'PendingMB',
                                'PendingVCores',
                                'ReservedMB',
                                'ReservedVCores']
                               ]




# push接口数据的标准数据结构
"""
push_data_dic = {
    "endpoint": socket.gethostname(),
    "metric": "",
    "timestamp": int(time.time()),
    "step": 60,
    "value": "",
    "counterType":"GAUGE",
    "tags": ""
}
"""

payload_list = []

#payload生成
def payload_generate(_metric = '', _data = '', _tags = ''):
    push_data_dic = {
        "endpoint": socket.gethostname(),
        "metric": _metric,
        "timestamp": int(time.time()),
        "step": 60,
        "value": _data,
        "counterType": "GAUGE",
        "tags": _tags
    }
    return push_data_dic

def crawl_simple_metric(_node_name,_port, name_list=[], metric_list=[]):
    port = _port
    node_name = _node_name
    capacity = ''
    dfsused = ''
    for i in range(len(name_list)):
        for j in range(len(metric_list[i])):
            url = root_url + ':' + port + '/jmx?get=' + name_list[i] + '::' + metric_list[i][j]
            try:
                data = json.loads(urllib2.urlopen(url).read())['beans'][0][metric_list[i][j]]
            except urllib2.URLError:
                continue
            except IndexError:
                pass
            except KeyError:
                pass
            else:
                if metric_list[i][j] == 'HeapMemoryUsage' or metric_list[i][j] == 'NonHeapMemoryUsage':
                    payload_list.append(payload_generate(metric_list[i][j]+'.max', data['max'],"service="+node_name))
                    payload_list.append(payload_generate(metric_list[i][j]+'.max', data['max'],"service="+node_name))
                #modify FSState
                elif metric_list[i][j] == 'FSState':
                    payload_list.append(payload_generate(metric_list[i][j], 1, "service=" + node_name))
                #modify dfspercent
                elif metric_list[i][j] =='DfsUsed':
                    capacity = data
                elif metric_list[i][j] =='Capacity':
                    dfsused = data
                    payload_list.append(payload_generate("DfsPercent","%.2f" % (float(dfsused)/float(capacity)), "service=" + node_name))
                else:
                    payload_list.append(payload_generate(metric_list[i][j], data, "service=" + node_name))


if __name__=="__main__":
    crawl_simple_metric(node_list[0], port_list[0], NameNode_name_list, NameNode_metric_list)
    crawl_simple_metric(node_list[1], port_list[1], DataNode_name_list, DataNode_metric_list)
    crawl_simple_metric(node_list[2], port_list[2], HMaster_name_list, HMaster_metric_list)
    crawl_simple_metric(node_list[3], port_list[3], HRegionServer_name_list, HRegionServer_metric_list)
    crawl_simple_metric(node_list[4], port_list[4], NodeManager_name_list, NodeManager_metric_list)
    crawl_simple_metric(node_list[5], port_list[5], ResourceManager_name_list, ResourceManager_metric_list)
    print json.dumps(payload_list)
