package X3;

import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;
import java.util.concurrent.atomic.AtomicReferenceArray;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;

/* JADX INFO: loaded from: classes.dex */
public final class m {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f2451b = AtomicReferenceFieldUpdater.newUpdater(m.class, Object.class, "lastScheduledTask$volatile");

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ AtomicIntegerFieldUpdater f2452c = AtomicIntegerFieldUpdater.newUpdater(m.class, "producerIndex$volatile");

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ AtomicIntegerFieldUpdater f2453d = AtomicIntegerFieldUpdater.newUpdater(m.class, "consumerIndex$volatile");
    public static final /* synthetic */ AtomicIntegerFieldUpdater e = AtomicIntegerFieldUpdater.newUpdater(m.class, "blockingTasksInBuffer$volatile");

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AtomicReferenceArray f2454a = new AtomicReferenceArray(128);
    private volatile /* synthetic */ int blockingTasksInBuffer$volatile;
    private volatile /* synthetic */ int consumerIndex$volatile;
    private volatile /* synthetic */ Object lastScheduledTask$volatile;
    private volatile /* synthetic */ int producerIndex$volatile;

    public final i a(i iVar) {
        AtomicIntegerFieldUpdater atomicIntegerFieldUpdater = f2452c;
        if (atomicIntegerFieldUpdater.get(this) - f2453d.get(this) == 127) {
            return iVar;
        }
        if (iVar.f2443b) {
            e.incrementAndGet(this);
        }
        int i4 = atomicIntegerFieldUpdater.get(this) & 127;
        while (true) {
            AtomicReferenceArray atomicReferenceArray = this.f2454a;
            if (atomicReferenceArray.get(i4) == null) {
                atomicReferenceArray.lazySet(i4, iVar);
                atomicIntegerFieldUpdater.incrementAndGet(this);
                return null;
            }
            Thread.yield();
        }
    }

    public final i b() {
        i iVar;
        while (true) {
            AtomicIntegerFieldUpdater atomicIntegerFieldUpdater = f2453d;
            int i4 = atomicIntegerFieldUpdater.get(this);
            if (i4 - f2452c.get(this) == 0) {
                return null;
            }
            int i5 = i4 & 127;
            if (atomicIntegerFieldUpdater.compareAndSet(this, i4, i4 + 1) && (iVar = (i) this.f2454a.getAndSet(i5, null)) != null) {
                if (iVar.f2443b) {
                    e.decrementAndGet(this);
                }
                return iVar;
            }
        }
    }

    public final i c(int i4, boolean z4) {
        int i5 = i4 & 127;
        AtomicReferenceArray atomicReferenceArray = this.f2454a;
        i iVar = (i) atomicReferenceArray.get(i5);
        if (iVar != null && iVar.f2443b == z4) {
            while (!atomicReferenceArray.compareAndSet(i5, iVar, null)) {
                if (atomicReferenceArray.get(i5) != iVar) {
                }
            }
            if (z4) {
                e.decrementAndGet(this);
            }
            return iVar;
        }
        return null;
    }
}
