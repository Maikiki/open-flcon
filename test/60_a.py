# encoding: utf-8
# author Froid
import urllib2
import json
import socket
import time
import requests


root_url = "http://192.168.55.10"

#节点、端口
node_list = ['NameNode',
             'DataNode',
             'HMaster',
             'HRegionServer',
             'NodeManager',
             'ResourceManager']

port_list = ('50070', '50075', '60010', '60030', '8042', '8088')

#JMX查询
NameNode_name_list = ['java.lang:type=Memory',
                      'Hadoop:service=NameNode,name=RpcActivityForPort8020',
                      #'Hadoop:service=NameNode,name=NameNodeActivity',
                      #'java.lang:type=GarbageCollector,name=PS%20MarkSweep',
                      'Hadoop:service=NameNode,name=FSNamesystemState',
                      'java.lang:type=OperatingSystem'
                      ]

DataNode_name_list = ['java.lang:type=Memory',
                      'Hadoop:service=DataNode,name=FSDatasetState-null',
                      'Hadoop:service=DataNode,name=RpcActivityForPort8010',
                      #'java.lang:type=GarbageCollector,name=PS%20MarkSweep',
                      'java.lang:type=OperatingSystem',
                      'Hadoop:service=DataNode,name=DataNodeActivity-NEOInciteDataNode-1-50010'
                      ]

HMaster_name_list = ['java.lang:type=Memory',
                     #'java.lang:type=GarbageCollector,name=ConcurrentMarkSweep',
                     'java.lang:type=OperatingSystem',
                     'Hadoop:service=HBase,name=IPC,sub=IPC'
                     ]

HRegionServer_name_list = ['java.lang:type=Memory',
                        #   'java.lang:type=GarbageCollector,name=ConcurrentMarkSweep',
                           'java.lang:type=OperatingSystem',
                           'Hadoop:service=HBase,name=RegionServer,sub=Server',
                           'Hadoop:service=HBase,name=IPC,sub=IPC'
                           ]

NodeManager_name_list = ['java.lang:type=Memory',
                         #'java.lang:type=GarbageCollector,name=PS%20MarkSweep',
                         'java.lang:type=OperatingSystem',
                         'Hadoop:service=NodeManager,name=RpcActivityForPort45454',
                         'Hadoop:service=NodeManager,name=NodeManagerMetrics',
                         ]

ResourceManager_name_list = ['java.lang:type=Memory',
                             #'java.lang:type=GarbageCollector,name=PS%20MarkSweep',
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
                        #['LastGcInfo'
                         #],
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
                        #['LastGcInfo'
                         #],
                        ['MaxFileDescriptorCount',
                         'OpenFileDescriptorCount'
                         ],
                        ['WriteBlockOpAvgTime'
                         ]
                        ]

HMaster_metric_list = [['HeapMemoryUsage',
                        'NonHeapMemoryUsage'
                        ],
                       #['LastGcInfo'
                        #],
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
                             #['LastGcInfo'
                              #],
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
                              'FlushTime_99th_percentile',
                              'Get_99th_percentile',
                              'SplitTime_99th_percentile'
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
def NameNode(_port = 0, name_list=[], metric_list=[]):
    port = _port
    #global payload_list
    for i in range(len(name_list)):
        for j in range(len(metric_list[i])):
            url = root_url + ':' + port + '/jmx?get=' + name_list[i] + '::' + metric_list[i][j]
            #print url
            data = json.loads(urllib2.urlopen(url).read())['beans'][0][metric_list[i][j]]
            if metric_list[i][j] == 'HeapMemoryUsage' or metric_list[i][j] == 'NonHeapMemoryUsage':
                payload_list.append({
                    "endpoint": socket.gethostname(),
                    "metric": metric_list[i][j]+'.max',
                    "timestamp": int(time.time()),
                    "step": 60,
                    "value": data['max'],
                    "counterType": "GAUGE",
                    "tags": ""
                })
                payload_list.append({
                    "endpoint": socket.gethostname(),
                    "metric": metric_list[i][j]+'.used',
                    "timestamp": int(time.time()),
                    "step": 60,
                    "value": data['used'],
                    "counterType": "GAUGE",
                    "tags": ""
                })
            else:
                #push_data_dic['value'] = data
                #push_data_dic['metric'] = metric_list[i][j]
                payload_list.append({
                        "endpoint": socket.gethostname(),
                        "metric": metric_list[i][j],
                        "timestamp": int(time.time()),
                        "step": 60,
                        "value":data,
                        "counterType": "GAUGE",
                        "tags": ""
                        })

#NameNode(port_list[0], NameNode_name_list, NameNode_metric_list)
#NameNode(port_list[1], DataNode_name_list, DataNode_metric_list)
#NameNode(port_list[2], HMaster_name_list, HMaster_metric_list)
#NameNode(port_list[3], HRegionServer_name_list, HRegionServer_metric_list)
#NameNode(port_list[4], NodeManager_name_list, NodeManager_metric_list)
#NameNode(port_list[5], ResourceManager_name_list, ResourceManager_metric_list)
  #  result = requests.post("http://127.0.0.1:1988/v1/push", data = json.dumps(payload_list))
  #  print result
print json.dumps([{
                        "endpoint": "falcon",
                        "metric": "aaa",
                        "timestamp": 1111,
                        "step": 60,
                        "value":333,
                        "counterType": "GAUGE",
                        "tags": ""
                        }])
#payload_list = []
