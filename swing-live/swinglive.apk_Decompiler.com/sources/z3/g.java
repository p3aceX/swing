package Z3;

import P3.m;
import java.util.concurrent.atomic.AtomicReferenceArray;

/* JADX INFO: loaded from: classes.dex */
public abstract class g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final f f2620a = new f(new byte[0], 0, 0, null);

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final int f2621b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final int f2622c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final int f2623d;
    public static final int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final AtomicReferenceArray f2624f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public static final AtomicReferenceArray f2625g;

    static {
        int iIntValue;
        int i4 = 0;
        int iHighestOneBit = Integer.highestOneBit((Runtime.getRuntime().availableProcessors() * 2) - 1);
        f2621b = iHighestOneBit;
        int i5 = iHighestOneBit / 2;
        int i6 = i5 >= 1 ? i5 : 1;
        f2622c = i6;
        String property = System.getProperty("kotlinx.io.pool.size.bytes", J3.i.a(System.getProperty("java.vm.name"), "Dalvik") ? "0" : "4194304");
        J3.i.d(property, "getProperty(...)");
        Integer numI0 = m.I0(property);
        if (numI0 != null && (iIntValue = numI0.intValue()) >= 0) {
            i4 = iIntValue;
        }
        f2623d = i4;
        int i7 = i4 / i6;
        if (i7 < 8192) {
            i7 = 8192;
        }
        e = i7;
        f2624f = new AtomicReferenceArray(iHighestOneBit);
        f2625g = new AtomicReferenceArray(i6);
    }

    public static final void a(f fVar) {
        J3.i.e(fVar, "segment");
        if (fVar.f2618f != null || fVar.f2619g != null) {
            throw new IllegalArgumentException("Failed requirement.");
        }
        i iVar = fVar.f2617d;
        if (iVar != null) {
            e eVar = (e) iVar;
            if (eVar.f2613b != 0) {
                int iDecrementAndGet = e.f2612c.decrementAndGet(eVar);
                if (iDecrementAndGet >= 0) {
                    return;
                }
                if (iDecrementAndGet != -1) {
                    throw new IllegalStateException(("Shared copies count is negative: " + (iDecrementAndGet + 1)).toString());
                }
                eVar.f2613b = 0;
            }
        }
        AtomicReferenceArray atomicReferenceArray = f2624f;
        int id = (int) ((((long) f2621b) - 1) & Thread.currentThread().getId());
        fVar.f2615b = 0;
        fVar.e = true;
        while (true) {
            f fVar2 = (f) atomicReferenceArray.get(id);
            f fVar3 = f2620a;
            if (fVar2 != fVar3) {
                int i4 = fVar2 != null ? fVar2.f2616c : 0;
                if (i4 < 65536) {
                    fVar.f2618f = fVar2;
                    fVar.f2616c = i4 + 8192;
                    while (!atomicReferenceArray.compareAndSet(id, fVar2, fVar)) {
                        if (atomicReferenceArray.get(id) != fVar2) {
                            break;
                        }
                    }
                    return;
                }
                if (f2623d <= 0) {
                    return;
                }
                fVar.f2615b = 0;
                fVar.e = true;
                int id2 = (int) ((((long) f2622c) - 1) & Thread.currentThread().getId());
                AtomicReferenceArray atomicReferenceArray2 = f2625g;
                int i5 = 0;
                while (true) {
                    f fVar4 = (f) atomicReferenceArray2.get(id2);
                    if (fVar4 != fVar3) {
                        int i6 = (fVar4 != null ? fVar4.f2616c : 0) + 8192;
                        if (i6 <= e) {
                            fVar.f2618f = fVar4;
                            fVar.f2616c = i6;
                            while (!atomicReferenceArray2.compareAndSet(id2, fVar4, fVar)) {
                                if (atomicReferenceArray2.get(id2) != fVar4) {
                                    break;
                                }
                            }
                            return;
                        }
                        int i7 = f2622c;
                        if (i5 >= i7) {
                            return;
                        }
                        i5++;
                        id2 = (id2 + 1) & (i7 - 1);
                    }
                }
            }
        }
    }

    public static final f b() {
        f fVar;
        f fVar2;
        AtomicReferenceArray atomicReferenceArray = f2624f;
        int id = (int) ((((long) f2621b) - 1) & Thread.currentThread().getId());
        do {
            fVar = f2620a;
            fVar2 = (f) atomicReferenceArray.getAndSet(id, fVar);
        } while (J3.i.a(fVar2, fVar));
        if (fVar2 != null) {
            atomicReferenceArray.set(id, fVar2.f2618f);
            fVar2.f2618f = null;
            fVar2.f2616c = 0;
            return fVar2;
        }
        atomicReferenceArray.set(id, null);
        if (f2623d <= 0) {
            return new f();
        }
        AtomicReferenceArray atomicReferenceArray2 = f2625g;
        int i4 = f2622c;
        int id2 = (int) (Thread.currentThread().getId() & (((long) i4) - 1));
        int i5 = 0;
        while (true) {
            f fVar3 = (f) atomicReferenceArray2.getAndSet(id2, fVar);
            if (!J3.i.a(fVar3, fVar)) {
                if (fVar3 != null) {
                    atomicReferenceArray2.set(id2, fVar3.f2618f);
                    fVar3.f2618f = null;
                    fVar3.f2616c = 0;
                    return fVar3;
                }
                atomicReferenceArray2.set(id2, null);
                if (i5 >= i4) {
                    return new f();
                }
                id2 = (id2 + 1) & (i4 - 1);
                i5++;
            }
        }
    }
}
