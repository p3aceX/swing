package R3;

import Q3.B;
import y3.AbstractC0760a;
import y3.InterfaceC0765f;

/* JADX INFO: loaded from: classes.dex */
public final class b extends AbstractC0760a implements InterfaceC0765f {
    private volatile Object _preHandler;

    public b() {
        super(B.f1564a);
        this._preHandler = this;
    }

    /* JADX WARN: Removed duplicated region for block: B:14:0x0032  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void A(java.lang.Throwable r6) {
        /*
            r5 = this;
            int r0 = android.os.Build.VERSION.SDK_INT
            r1 = 26
            if (r1 > r0) goto L4f
            r1 = 28
            if (r0 >= r1) goto L4f
            java.lang.Object r0 = r5._preHandler
            r1 = 0
            r2 = 0
            if (r0 == r5) goto L13
            java.lang.reflect.Method r0 = (java.lang.reflect.Method) r0
            goto L35
        L13:
            java.lang.Class<java.lang.Thread> r0 = java.lang.Thread.class
            java.lang.String r3 = "getUncaughtExceptionPreHandler"
            java.lang.Class[] r4 = new java.lang.Class[r1]     // Catch: java.lang.Throwable -> L32
            java.lang.reflect.Method r0 = r0.getDeclaredMethod(r3, r4)     // Catch: java.lang.Throwable -> L32
            int r3 = r0.getModifiers()     // Catch: java.lang.Throwable -> L32
            boolean r3 = java.lang.reflect.Modifier.isPublic(r3)     // Catch: java.lang.Throwable -> L32
            if (r3 == 0) goto L32
            int r3 = r0.getModifiers()     // Catch: java.lang.Throwable -> L32
            boolean r3 = java.lang.reflect.Modifier.isStatic(r3)     // Catch: java.lang.Throwable -> L32
            if (r3 == 0) goto L32
            goto L33
        L32:
            r0 = r2
        L33:
            r5._preHandler = r0
        L35:
            if (r0 == 0) goto L3e
            java.lang.Object[] r1 = new java.lang.Object[r1]
            java.lang.Object r0 = r0.invoke(r2, r1)
            goto L3f
        L3e:
            r0 = r2
        L3f:
            boolean r1 = r0 instanceof java.lang.Thread.UncaughtExceptionHandler
            if (r1 == 0) goto L46
            r2 = r0
            java.lang.Thread$UncaughtExceptionHandler r2 = (java.lang.Thread.UncaughtExceptionHandler) r2
        L46:
            if (r2 == 0) goto L4f
            java.lang.Thread r0 = java.lang.Thread.currentThread()
            r2.uncaughtException(r0, r6)
        L4f:
            return
        */
        throw new UnsupportedOperationException("Method not decompiled: R3.b.A(java.lang.Throwable):void");
    }
}
