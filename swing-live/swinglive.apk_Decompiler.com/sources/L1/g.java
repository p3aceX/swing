package l1;

import A.C0003c;
import O.RunnableC0093d;
import android.util.Log;
import com.google.firebase.components.ComponentRegistrar;
import e1.AbstractC0367g;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicReference;
import o1.InterfaceC0580a;
import o3.C0592H;
import q1.InterfaceC0634a;

/* JADX INFO: loaded from: classes.dex */
public final class g implements b {

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final e f5599n = new e(0);
    public final l e;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final C0592H f5605m;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final HashMap f5600a = new HashMap();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final HashMap f5601b = new HashMap();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final HashMap f5602c = new HashMap();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final HashSet f5603d = new HashSet();

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final AtomicReference f5604f = new AtomicReference();

    public g(ArrayList arrayList, ArrayList arrayList2, C0592H c0592h) {
        l lVar = new l();
        new HashMap();
        lVar.f5614a = new ArrayDeque();
        this.e = lVar;
        this.f5605m = c0592h;
        ArrayList<C0522a> arrayList3 = new ArrayList();
        arrayList3.add(C0522a.b(lVar, l.class, o1.b.class, InterfaceC0580a.class));
        arrayList3.add(C0522a.b(this, g.class, new Class[0]));
        Iterator it = arrayList2.iterator();
        while (it.hasNext()) {
            C0522a c0522a = (C0522a) it.next();
            if (c0522a != null) {
                arrayList3.add(c0522a);
            }
        }
        ArrayList arrayList4 = new ArrayList();
        Iterator it2 = arrayList.iterator();
        while (it2.hasNext()) {
            arrayList4.add(it2.next());
        }
        ArrayList arrayList5 = new ArrayList();
        synchronized (this) {
            Iterator it3 = arrayList4.iterator();
            while (it3.hasNext()) {
                try {
                    ComponentRegistrar componentRegistrar = (ComponentRegistrar) ((InterfaceC0634a) it3.next()).get();
                    if (componentRegistrar != null) {
                        arrayList3.addAll(this.f5605m.j(componentRegistrar));
                        it3.remove();
                    }
                } catch (m e) {
                    it3.remove();
                    Log.w("ComponentDiscovery", "Invalid component registrar.", e);
                }
            }
            Iterator it4 = arrayList3.iterator();
            while (it4.hasNext()) {
                Object[] array = ((C0522a) it4.next()).f5589a.toArray();
                int length = array.length;
                int i4 = 0;
                while (true) {
                    if (i4 < length) {
                        Object obj = array[i4];
                        if (obj.toString().contains("kotlinx.coroutines.CoroutineDispatcher")) {
                            if (this.f5603d.contains(obj.toString())) {
                                it4.remove();
                                break;
                            }
                            this.f5603d.add(obj.toString());
                        }
                        i4++;
                    }
                }
            }
            if (this.f5600a.isEmpty()) {
                e1.k.o(arrayList3);
            } else {
                ArrayList arrayList6 = new ArrayList(this.f5600a.keySet());
                arrayList6.addAll(arrayList3);
                e1.k.o(arrayList6);
            }
            for (C0522a c0522a2 : arrayList3) {
                this.f5600a.put(c0522a2, new n(new f(0, this, c0522a2)));
            }
            arrayList5.addAll(i(arrayList3));
            arrayList5.addAll(j());
            h();
        }
        Iterator it5 = arrayList5.iterator();
        while (it5.hasNext()) {
            ((Runnable) it5.next()).run();
        }
        Boolean bool = (Boolean) this.f5604f.get();
        if (bool != null) {
            e(this.f5600a, bool.booleanValue());
        }
    }

    public final void e(HashMap map, boolean z4) {
        ArrayDeque arrayDeque;
        for (Map.Entry entry : map.entrySet()) {
            C0522a c0522a = (C0522a) entry.getKey();
            c0522a.getClass();
        }
        l lVar = this.e;
        synchronized (lVar) {
            arrayDeque = lVar.f5614a;
            if (arrayDeque != null) {
                lVar.f5614a = null;
            } else {
                arrayDeque = null;
            }
        }
        if (arrayDeque != null) {
            Iterator it = arrayDeque.iterator();
            if (it.hasNext()) {
                it.next().getClass();
                throw new ClassCastException();
            }
        }
    }

    @Override // l1.b
    public final synchronized InterfaceC0634a f(r rVar) {
        AbstractC0367g.a(rVar, "Null interface requested.");
        return (InterfaceC0634a) this.f5601b.get(rVar);
    }

    @Override // l1.b
    public final synchronized InterfaceC0634a g(r rVar) {
        o oVar = (o) this.f5602c.get(rVar);
        if (oVar != null) {
            return oVar;
        }
        return f5599n;
    }

    public final void h() {
        for (C0522a c0522a : this.f5600a.keySet()) {
            for (j jVar : c0522a.f5590b) {
                if (jVar.f5612b == 2 && !this.f5602c.containsKey(jVar.f5611a)) {
                    HashMap map = this.f5602c;
                    r rVar = jVar.f5611a;
                    Set set = Collections.EMPTY_SET;
                    o oVar = new o();
                    oVar.f5619b = null;
                    oVar.f5618a = Collections.newSetFromMap(new ConcurrentHashMap());
                    oVar.f5618a.addAll(set);
                    map.put(rVar, oVar);
                } else if (this.f5601b.containsKey(jVar.f5611a)) {
                    continue;
                } else {
                    int i4 = jVar.f5612b;
                    if (i4 == 1) {
                        throw new k("Unsatisfied dependency for component " + c0522a + ": " + jVar.f5611a);
                    }
                    if (i4 != 2) {
                        HashMap map2 = this.f5601b;
                        r rVar2 = jVar.f5611a;
                        C0003c c0003c = p.f5620c;
                        e eVar = p.f5621d;
                        p pVar = new p();
                        pVar.f5622a = c0003c;
                        pVar.f5623b = eVar;
                        map2.put(rVar2, pVar);
                    }
                }
            }
        }
    }

    public final ArrayList i(ArrayList arrayList) {
        ArrayList arrayList2 = new ArrayList();
        Iterator it = arrayList.iterator();
        while (it.hasNext()) {
            C0522a c0522a = (C0522a) it.next();
            if (c0522a.f5591c == 0) {
                InterfaceC0634a interfaceC0634a = (InterfaceC0634a) this.f5600a.get(c0522a);
                for (r rVar : c0522a.f5589a) {
                    HashMap map = this.f5601b;
                    if (map.containsKey(rVar)) {
                        arrayList2.add(new RunnableC0093d(8, (p) ((InterfaceC0634a) map.get(rVar)), interfaceC0634a));
                    } else {
                        map.put(rVar, interfaceC0634a);
                    }
                }
            }
        }
        return arrayList2;
    }

    public final ArrayList j() {
        ArrayList arrayList = new ArrayList();
        HashMap map = new HashMap();
        for (Map.Entry entry : this.f5600a.entrySet()) {
            C0522a c0522a = (C0522a) entry.getKey();
            if (c0522a.f5591c != 0) {
                InterfaceC0634a interfaceC0634a = (InterfaceC0634a) entry.getValue();
                for (r rVar : c0522a.f5589a) {
                    if (!map.containsKey(rVar)) {
                        map.put(rVar, new HashSet());
                    }
                    ((Set) map.get(rVar)).add(interfaceC0634a);
                }
            }
        }
        for (Map.Entry entry2 : map.entrySet()) {
            Object key = entry2.getKey();
            HashMap map2 = this.f5602c;
            if (map2.containsKey(key)) {
                o oVar = (o) map2.get(entry2.getKey());
                Iterator it = ((Set) entry2.getValue()).iterator();
                while (it.hasNext()) {
                    arrayList.add(new RunnableC0093d(9, oVar, (InterfaceC0634a) it.next()));
                }
            } else {
                r rVar2 = (r) entry2.getKey();
                Set set = (Set) ((Collection) entry2.getValue());
                o oVar2 = new o();
                oVar2.f5619b = null;
                oVar2.f5618a = Collections.newSetFromMap(new ConcurrentHashMap());
                oVar2.f5618a.addAll(set);
                map2.put(rVar2, oVar2);
            }
        }
        return arrayList;
    }
}
