/*! odometer 0.3.6 */
(function () {
    var a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y;
    p = '<span class="odometer-value"></span>', m = '<span class="odometer-ribbon"><span class="odometer-ribbon-inner">' + p + "</span></span>", d = '<span class="odometer-digit"><span class="odometer-digit-spacer">8</span><span class="odometer-digit-inner">' + m + "</span></span>", g = '<span class="odometer-formatting-mark"></span>', c = ",ddd", h = 60, f = 2e3, a = 20, i = 2, e = .5, j = 1e3 / h, b = 1e3 / a, n = "transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd", t = document.createElement("div").style, o = null != t.transition || null != t.webkitTransition || null != t.mozTransition || null != t.oTransition, s = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame || window.msRequestAnimationFrame, k = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver, q = function (a) {
        var b;
        return b = document.createElement("div"), b.innerHTML = a, b.children[0]
    }, r = function () {
        var a, b;
        return null != (a = null != (b = window.performance) ? b.now() : void 0) ? a : +new Date
    }, v = !1, (u = function () {
        var a, b, c, d, e;
        if (!v && null != window.jQuery) {
            for (v = !0, d = ["html", "text"], e = [], b = 0, c = d.length; c > b; b++)a = d[b], e.push(function (a) {
                var b;
                return b = window.jQuery.fn[a], window.jQuery.fn[a] = function (a) {
                    return null == a || null == this[0].odometer ? b.apply(this, arguments) : this[0].odometer.update(a)
                }
            }(a));
            return e
        }
    })(), setTimeout(u, 0), l = function () {
        function a(b) {
            var d, e, g, h, k, l, m, n, o, p, q, r, s, t, u, v = this;
            if (this.options = b, this.el = this.options.el, null != this.el.odometer)return this.el.odometer;
            for (this.el.odometer = this, s = a.options, h = o = 0, q = s.length; q > o; h = ++o)e = s[h], null == this.options[e] && (this.options[e] = h);
            this.value = this.cleanValue(null != (t = this.options.value) ? t : ""), null == (k = this.options).format && (k.format = c), (l = this.options).format || (l.format = "d"), null == (m = this.options).duration && (m.duration = f), this.MAX_VALUES = 0 | this.options.duration / j / i, this.renderInside(), this.render();
            try {
                for (u = ["HTML", "Text"], n = function (a) {
                    return Object.defineProperty(v.el, "inner" + a, {
                        get: function () {
                            return v.inside["outer" + a]
                        }, set: function (a) {
                            return v.update(v.cleanValue(a))
                        }
                    })
                }, p = 0, r = u.length; r > p; p++)g = u[p], n(g)
            } catch (w) {
                d = w, this.watchForMutations()
            }
        }

        return a.prototype.renderInside = function () {
            return this.inside = document.createElement("div"), this.inside.className = "odometer-inside", this.el.innerHTML = "", this.el.appendChild(this.inside)
        }, a.prototype.watchForMutations = function () {
            var a, b = this;
            if (null != k)try {
                return null == this.observer && (this.observer = new k(function () {
                    var a;
                    return a = b.el.innerText, b.renderInside(), b.render(b.value), b.update(a)
                })), this.watchMutations = !0, this.startWatchingMutations()
            } catch (c) {
                a = c
            }
        }, a.prototype.startWatchingMutations = function () {
            return this.watchMutations ? this.observer.observe(this.el, {childList: !0}) : void 0
        }, a.prototype.stopWatchingMutations = function () {
            var a;
            return null != (a = this.observer) ? a.disconnect() : void 0
        }, a.prototype.cleanValue = function (a) {
            return parseInt(a.toString().replace(/[.,]/g, ""), 10) || 0
        }, a.prototype.bindTransitionEnd = function () {
            var a, b, c, d, e, f, g = this;
            if (!this.transitionEndBound) {
                for (this.transitionEndBound = !0, b = !1, e = n.split(" "), f = [], c = 0, d = e.length; d > c; c++)a = e[c], f.push(this.el.addEventListener(a, function () {
                    return b ? !0 : (b = !0, setTimeout(function () {
                        return g.render(), b = !1
                    }, 0), !0)
                }, !1));
                return f
            }
        }, a.prototype.resetFormat = function () {
            return this.format = this.options.format.split("").reverse().join("")
        }, a.prototype.render = function (a) {
            var b, c, d, e, f, g, h, i, j;
            for (null == a && (a = this.value), this.stopWatchingMutations(), this.resetFormat(), this.inside.innerHTML = "", b = this.el.className.split(" "), e = [], f = 0, h = b.length; h > f; f++)c = b[f], c.length && (/^odometer(-|$)/.test(c) || e.push(c));
            for (e.push("odometer"), o || e.push("odometer-no-transitions"), this.options.theme ? e.push("odometer-theme-" + this.options.theme) : e.push("odometer-auto-theme"), this.el.className = e.join(" "), this.ribbons = {}, this.digits = [], j = a.toString().split("").reverse(), g = 0, i = j.length; i > g; g++)d = j[g], this.addDigit(d);
            return this.startWatchingMutations()
        }, a.prototype.update = function (a) {
            var b, c = this;
            return a = this.cleanValue(a), (b = a - this.value) ? (this.el.className += b > 0 ? " odometer-animating-up" : " odometer-animating-down", this.stopWatchingMutations(), this.animate(a), this.startWatchingMutations(), setTimeout(function () {
                return c.el.offsetHeight, c.el.className += " odometer-animating"
            }, 0), this.value = a) : void 0
        }, a.prototype.renderDigit = function () {
            return q(d)
        }, a.prototype.insertDigit = function (a) {
            return this.inside.children.length ? this.inside.insertBefore(a, this.inside.children[0]) : this.inside.appendChild(a)
        }, a.prototype.addSpacer = function (a) {
            var b;
            return b = q(g), b.innerHTML = a, this.insertDigit(b)
        }, a.prototype.addDigit = function (a) {
            var b, c, d;
            if ("-" === a)return this.addSpacer("-"), void 0;
            for (d = !1; ;) {
                if ("-" === a)break;
                if (!this.format.length) {
                    if (d)throw new Error("Bad odometer format without digits");
                    this.resetFormat(), d = !0
                }
                if (b = this.format[0], this.format = this.format.substring(1), "d" === b)break;
                this.addSpacer(b)
            }
            return c = this.renderDigit(), c.querySelector(".odometer-value").innerHTML = a, this.digits.push(c), this.insertDigit(c)
        }, a.prototype.animate = function (a) {
            return o ? this.animateSlide(a) : this.animateCount(a)
        }, a.prototype.animateCount = function (a) {
            var c, d, e, f, g, h = this;
            if (d = +a - this.value)return f = e = r(), c = this.value, (g = function () {
                var i, j, k;
                return r() - f > h.options.duration ? (h.value = a, h.render(), void 0) : (i = r() - e, i > b && (e = r(), k = i / h.options.duration, j = d * k, c += j, h.render(Math.round(c))), null != window.requestAnimationFrame ? s(g) : setTimeout(g, b))
            })()
        }, a.prototype.animateSlide = function (a) {
            var b, c, d, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y;
            if (d = a - this.value) {
                for (this.bindTransitionEnd(), f = Math.ceil(Math.log(Math.max(Math.abs(a), Math.abs(this.value)) + 1) / Math.log(10)), g = [], b = 0, l = r = 0; f >= 0 ? f > r : r > f; l = f >= 0 ? ++r : --r) {
                    if (p = Math.floor(this.value / Math.pow(10, f - l - 1)), i = Math.floor(a / Math.pow(10, f - l - 1)), h = i - p, Math.abs(h) > this.MAX_VALUES) {
                        for (k = [], m = h / (this.MAX_VALUES + this.MAX_VALUES * b * e), c = p; h > 0 && i > c || 0 > h && c > i;)k.push(Math.round(c)), c += m;
                        k[k.length - 1] !== i && k.push(i), b++
                    } else k = function () {
                        x = [];
                        for (var a = p; i >= p ? i >= a : a >= i; i >= p ? a++ : a--)x.push(a);
                        return x
                    }.apply(this);
                    for (l = s = 0, u = k.length; u > s; l = ++s)j = k[l], k[l] = Math.abs(j % 10);
                    g.push(k)
                }
                for (w = g.reverse(), y = [], l = t = 0, v = w.length; v > t; l = ++t)k = w[l], this.digits[l] || this.addDigit(" "), null == (q = this.ribbons)[l] && (q[l] = this.digits[l].querySelector(".odometer-ribbon-inner")), this.ribbons[l].innerHTML = "", 0 > d && (k = k.reverse()), y.push(function () {
                    var a, b, c;
                    for (c = [], n = b = 0, a = k.length; a > b; n = ++b)j = k[n], o = document.createElement("div"), o.className = "odometer-value", o.innerHTML = j, this.ribbons[l].appendChild(o), n === k.length - 1 && (o.className += " odometer-last-value"), 0 === n ? c.push(o.className += " odometer-first-value") : c.push(void 0);
                    return c
                }.call(this));
                return y
            }
        }, a
    }(), l.options = null != (x = window.odometerOptions) ? x : {}, setTimeout(function () {
        var a, b, c, d, e;
        if (window.odometerOptions) {
            d = window.odometerOptions, e = [];
            for (a in d)b = d[a], e.push(null != (c = l.options)[a] ? (c = l.options)[a] : c[a] = b);
            return e
        }
    }, 0), l.init = function () {
        var a, b, c, d, e;
        for (b = document.querySelectorAll(l.options.selector || ".odometer"), e = [], c = 0, d = b.length; d > c; c++)a = b[c], e.push(a.odometer = new l({
            el: a,
            value: a.innerText
        }));
        return e
    }, null != (null != (y = document.documentElement) ? y.doScroll : void 0) && null != document.createEventObject ? (w = document.onreadystatechange, document.onreadystatechange = function () {
        return "complete" === document.readyState && l.options.auto !== !1 && l.init(), null != w ? w.apply(this, arguments) : void 0
    }) : document.addEventListener("DOMContentLoaded", function () {
        return l.options.auto !== !1 ? l.init() : void 0
    }, !1), window.Odometer = l
}).call(this);