package T3;

import Q3.C0141m;
import Q3.L;
import java.lang.reflect.InvocationTargetException;
import java.util.concurrent.atomic.AtomicReference;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import y3.InterfaceC0762c;
import y3.InterfaceC0767h;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class q extends U3.b implements d, e, U3.i {
    public static final /* synthetic */ AtomicReferenceFieldUpdater e = AtomicReferenceFieldUpdater.newUpdater(q.class, Object.class, "_state$volatile");
    private volatile /* synthetic */ Object _state$volatile;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f2071d;

    public q(Object obj) {
        this._state$volatile = obj;
    }

    public final void a(Object obj) {
        if (obj == null) {
            obj = U3.k.f2122a;
        }
        e(null, obj);
    }

    /* JADX WARN: Code restructure failed: missing block: B:104:0x0145, code lost:
    
        if (r5 != r3) goto L83;
     */
    /* JADX WARN: Code restructure failed: missing block: B:81:0x0142, code lost:
    
        if (r4 != r3) goto L83;
     */
    /* JADX WARN: Removed duplicated region for block: B:52:0x00ce A[Catch: all -> 0x003f, TryCatch #2 {all -> 0x003f, blocks: (B:14:0x0039, B:50:0x00c6, B:52:0x00ce, B:55:0x00d5, B:56:0x00d9, B:58:0x00dc, B:68:0x00fd, B:71:0x010d, B:72:0x0127, B:78:0x0139, B:75:0x0130, B:77:0x0136, B:60:0x00e2, B:64:0x00e9, B:21:0x0054, B:24:0x005f, B:49:0x00b7), top: B:102:0x0027 }] */
    /* JADX WARN: Removed duplicated region for block: B:58:0x00dc A[Catch: all -> 0x003f, TryCatch #2 {all -> 0x003f, blocks: (B:14:0x0039, B:50:0x00c6, B:52:0x00ce, B:55:0x00d5, B:56:0x00d9, B:58:0x00dc, B:68:0x00fd, B:71:0x010d, B:72:0x0127, B:78:0x0139, B:75:0x0130, B:77:0x0136, B:60:0x00e2, B:64:0x00e9, B:21:0x0054, B:24:0x005f, B:49:0x00b7), top: B:102:0x0027 }] */
    /* JADX WARN: Removed duplicated region for block: B:62:0x00e6  */
    /* JADX WARN: Removed duplicated region for block: B:63:0x00e8  */
    /* JADX WARN: Removed duplicated region for block: B:66:0x00fb  */
    /* JADX WARN: Removed duplicated region for block: B:70:0x010c  */
    /* JADX WARN: Removed duplicated region for block: B:71:0x010d A[Catch: all -> 0x003f, TryCatch #2 {all -> 0x003f, blocks: (B:14:0x0039, B:50:0x00c6, B:52:0x00ce, B:55:0x00d5, B:56:0x00d9, B:58:0x00dc, B:68:0x00fd, B:71:0x010d, B:72:0x0127, B:78:0x0139, B:75:0x0130, B:77:0x0136, B:60:0x00e2, B:64:0x00e9, B:21:0x0054, B:24:0x005f, B:49:0x00b7), top: B:102:0x0027 }] */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0017  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:70:0x010c -> B:50:0x00c6). Please report as a decompilation issue!!! */
    @Override // T3.d
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object b(T3.e r18, y3.InterfaceC0762c r19) {
        /*
            Method dump skipped, instruction units count: 362
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: T3.q.b(T3.e, y3.c):java.lang.Object");
    }

    @Override // T3.e
    public final Object c(Object obj, InterfaceC0762c interfaceC0762c) {
        a(obj);
        return w3.i.f6729a;
    }

    @Override // U3.i
    public final d d(InterfaceC0767h interfaceC0767h, int i4, S3.c cVar) {
        return ((((i4 < 0 || i4 >= 2) && i4 != -2) || cVar != S3.c.f1814b) && !((i4 == 0 || i4 == -3) && cVar == S3.c.f1813a)) ? new U3.g(this, interfaceC0767h, i4, cVar) : this;
    }

    public final boolean e(Object obj, Object obj2) throws IllegalAccessException, L, InvocationTargetException {
        int i4;
        s[] sVarArr;
        C0779j c0779j;
        synchronized (this) {
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = e;
            Object obj3 = atomicReferenceFieldUpdater.get(this);
            if (obj != null && !J3.i.a(obj3, obj)) {
                return false;
            }
            if (J3.i.a(obj3, obj2)) {
                return true;
            }
            atomicReferenceFieldUpdater.set(this, obj2);
            int i5 = this.f2071d;
            if ((i5 & 1) != 0) {
                this.f2071d = i5 + 2;
                return true;
            }
            int i6 = i5 + 1;
            this.f2071d = i6;
            s[] sVarArr2 = this.f2102a;
            while (true) {
                if (sVarArr2 != null) {
                    for (s sVar : sVarArr2) {
                        if (sVar != null) {
                            AtomicReference atomicReference = sVar.f2074a;
                            while (true) {
                                Object obj4 = atomicReference.get();
                                if (obj4 != null && obj4 != (c0779j = r.f2073b)) {
                                    C0779j c0779j2 = r.f2072a;
                                    if (obj4 != c0779j2) {
                                        while (!atomicReference.compareAndSet(obj4, c0779j2)) {
                                            if (atomicReference.get() != obj4) {
                                                break;
                                            }
                                        }
                                        ((C0141m) obj4).resumeWith(w3.i.f6729a);
                                        break;
                                    }
                                    while (!atomicReference.compareAndSet(obj4, c0779j)) {
                                        if (atomicReference.get() != obj4) {
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                synchronized (this) {
                    i4 = this.f2071d;
                    if (i4 == i6) {
                        this.f2071d = i6 + 1;
                        return true;
                    }
                    sVarArr = this.f2102a;
                }
                sVarArr2 = sVarArr;
                i6 = i4;
            }
        }
    }
}
