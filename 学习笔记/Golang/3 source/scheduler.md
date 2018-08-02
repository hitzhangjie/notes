# how does a goroutine scheduled?


```plantuml
hide footbox

"startm(fn, _p_)" as startm -> startm : if _p_ is nil, _p_ = pidleget()
startm -> startm : if mp := mget() is nil, mp = newm(fn, _p_)
startm -> "newm(fn, _p_)" as newm : create a new m
newm -> "allocm(_p_, fn)" as allocm
allocm --> newm : mp
newm -> newm : mp.nextp.set(_p_)
newm -> newm : ...
newm -> newm1 : newm1(mp)
newm1 -> "newosproc(mp, mp.g0.stack.hi)" as newosproc
newosproc -> newosproc : clone,\n- flags,\n- mp,\n- mp.g0,\n- mstart)
newosproc -> mstart : m runs
mstart -> mstart1
mstart1 -> mstart1 : _g_ := getg()
mstart1 -> mstart1 : minit() to enable signal
mstart1 -> "acquirep(_g_.m.nextp.ptr())" as acquirep
note right: sets m.p = m.nextp\nclear m.nextp
acquirep --> mstart1
mstart1 -> schedule : schedule one round goroutines
schedule --> mstart1
mstart1 --> mstart
mstart -> mexit
mexit --> mstart
mstart --> newosproc
newosproc --> newm1
newm1 --> newm
newm --> startm
startm -> startm : mp.nextp.set(_p)
startm -> startm : notewakeup(&mp.park)
```

