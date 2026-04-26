package n3;

import java.util.concurrent.atomic.AtomicLongFieldUpdater;
import java.util.concurrent.atomic.AtomicReferenceArray;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;

/* JADX INFO: loaded from: classes.dex */
public final class o {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f5922a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f5923b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final AtomicReferenceArray f5924c;
    private volatile /* synthetic */ Object nextRef = null;
    private volatile /* synthetic */ long stateRef = 0;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final k f5921f = new k(1);

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f5920d = AtomicReferenceFieldUpdater.newUpdater(o.class, Object.class, "nextRef");
    public static final /* synthetic */ AtomicLongFieldUpdater e = AtomicLongFieldUpdater.newUpdater(o.class, "stateRef");

    public o(int i4) {
        this.f5922a = i4;
        int i5 = i4 - 1;
        this.f5923b = i5;
        this.f5924c = new AtomicReferenceArray(i4);
        if (i5 > 1073741823) {
            throw new IllegalStateException("Check failed.");
        }
        if ((i4 & i5) != 0) {
            throw new IllegalStateException("Check failed.");
        }
    }

    public final int a(r rVar) {
        long j4;
        int i4;
        J3.i.e(rVar, "element");
        do {
            j4 = this.stateRef;
            if ((3458764513820540928L & j4) != 0) {
                return (2305843009213693952L & j4) != 0 ? 2 : 1;
            }
            i4 = (int) ((1152921503533105152L & j4) >> 30);
            int i5 = this.f5923b;
            if (((i4 + 2) & i5) == (((int) (1073741823 & j4)) & i5)) {
                return 1;
            }
        } while (!e.compareAndSet(this, j4, (((long) ((i4 + 1) & 1073741823)) << 30) | ((-1152921503533105153L) & j4)));
        this.f5924c.set(this.f5923b & i4, rVar);
        o oVarD = this;
        while ((oVarD.stateRef & 1152921504606846976L) != 0) {
            oVarD = oVarD.d();
            AtomicReferenceArray atomicReferenceArray = oVarD.f5924c;
            int i6 = oVarD.f5923b & i4;
            Object obj = atomicReferenceArray.get(i6);
            if ((obj instanceof n) && ((n) obj).f5919a == i4) {
                atomicReferenceArray.set(i6, rVar);
            } else {
                oVarD = null;
            }
            if (oVarD == null) {
                return 0;
            }
        }
        return 0;
    }

    public final boolean b() {
        long j4;
        do {
            j4 = this.stateRef;
            if ((j4 & 2305843009213693952L) != 0) {
                return true;
            }
            if ((1152921504606846976L & j4) != 0) {
                return false;
            }
        } while (!e.compareAndSet(this, j4, j4 | 2305843009213693952L));
        return true;
    }

    public final boolean c() {
        long j4 = this.stateRef;
        return ((int) (1073741823 & j4)) == ((int) ((j4 & 1152921503533105152L) >> 30));
    }

    public final o d() {
        long j4;
        o oVar;
        while (true) {
            j4 = this.stateRef;
            if ((j4 & 1152921504606846976L) != 0) {
                oVar = this;
                break;
            }
            long j5 = j4 | 1152921504606846976L;
            oVar = this;
            if (e.compareAndSet(oVar, j4, j5)) {
                j4 = j5;
                break;
            }
        }
        while (true) {
            o oVar2 = (o) oVar.nextRef;
            if (oVar2 != null) {
                return oVar2;
            }
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f5920d;
            o oVar3 = new o(oVar.f5922a * 2);
            int i4 = (int) (1073741823 & j4);
            int i5 = (int) ((1152921503533105152L & j4) >> 30);
            while (true) {
                int i6 = oVar.f5923b;
                int i7 = i4 & i6;
                if (i7 == (i6 & i5)) {
                    break;
                }
                AtomicReferenceArray atomicReferenceArray = oVar3.f5924c;
                int i8 = oVar3.f5923b & i4;
                Object nVar = oVar.f5924c.get(i7);
                if (nVar == null) {
                    nVar = new n(i4);
                }
                atomicReferenceArray.set(i8, nVar);
                i4++;
            }
            oVar3.stateRef = (-1152921504606846977L) & j4;
            while (!atomicReferenceFieldUpdater.compareAndSet(this, null, oVar3) && atomicReferenceFieldUpdater.get(this) == null) {
            }
        }
    }

    public final Object e() {
        Object obj;
        long j4 = this.stateRef;
        if ((j4 & 1152921504606846976L) != 0) {
            return f5921f;
        }
        int i4 = (int) (j4 & 1073741823);
        int i5 = this.f5923b;
        int i6 = ((int) ((1152921503533105152L & j4) >> 30)) & i5;
        int i7 = i5 & i4;
        if (i6 == i7 || (obj = this.f5924c.get(i7)) == null || (obj instanceof n)) {
            return null;
        }
        long j5 = (i4 + 1) & 1073741823;
        if (e.compareAndSet(this, j4, (j4 & (-1073741824)) | j5)) {
            this.f5924c.set(this.f5923b & i4, null);
            return obj;
        }
        o oVarD = this;
        while (true) {
            long j6 = oVarD.stateRef;
            int i8 = (int) (j6 & 1073741823);
            if (i8 != i4) {
                throw new IllegalStateException("This queue can have only one consumer");
            }
            if ((j6 & 1152921504606846976L) != 0) {
                oVarD = oVarD.d();
            } else {
                o oVar = oVarD;
                if (e.compareAndSet(oVar, j6, (j6 & (-1073741824)) | j5)) {
                    oVar.f5924c.set(oVar.f5923b & i8, null);
                    oVarD = null;
                } else {
                    oVarD = oVar;
                }
            }
            if (oVarD == null) {
                return obj;
            }
        }
    }
}
