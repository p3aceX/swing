package y2;

import Q3.D;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class e extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f6874a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ g f6875b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ int f6876c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public e(g gVar, int i4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f6875b = gVar;
        this.f6876c = i4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new e(this.f6875b, this.f6876c, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((e) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Removed duplicated region for block: B:11:0x0022  */
    /* JADX WARN: Removed duplicated region for block: B:16:0x0033  */
    /* JADX WARN: Removed duplicated region for block: B:28:0x007b  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:12:0x002a -> B:14:0x002d). Please report as a decompilation issue!!! */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r8) {
        /*
            r7 = this;
            z3.a r0 = z3.EnumC0789a.f6999a
            int r1 = r7.f6874a
            r2 = 1
            if (r1 == 0) goto L15
            if (r1 != r2) goto Ld
            e1.AbstractC0367g.M(r8)
            goto L2d
        Ld:
            java.lang.IllegalStateException r8 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r8.<init>(r0)
            throw r8
        L15:
            e1.AbstractC0367g.M(r8)
        L18:
            y2.g r8 = r7.f6875b
            java.util.concurrent.atomic.AtomicBoolean r8 = r8.f6892j
            boolean r8 = r8.get()
            if (r8 == 0) goto L7b
            r7.f6874a = r2
            r3 = 5000(0x1388, double:2.4703E-320)
            java.lang.Object r8 = Q3.F.h(r3, r7)
            if (r8 != r0) goto L2d
            return r0
        L2d:
            y2.g r8 = r7.f6875b
            S1.a r1 = r8.f6891i
            if (r1 == 0) goto L18
            int r3 = r7.f6876c
            java.util.concurrent.atomic.AtomicInteger r4 = r8.f6894l
            int r4 = r4.get()
            r5 = 10
            if (r4 <= r5) goto L18
            java.util.concurrent.atomic.AtomicBoolean r4 = r8.f6881C
            boolean r4 = r4.get()
            if (r4 != 0) goto L18
            double r3 = (double) r3
            r5 = 4602678819172646912(0x3fe0000000000000, double:0.5)
            double r3 = r3 * r5
            int r3 = (int) r3
            int r3 = r3 * 1000
            r4 = 400000(0x61a80, float:5.6052E-40)
            int r3 = java.lang.Math.max(r4, r3)
            Q1.b r1 = r1.f1796b
            boolean r4 = r1.f425h
            if (r4 == 0) goto L75
            r1.f1547B = r3
            android.os.Bundle r4 = new android.os.Bundle
            r4.<init>()
            java.lang.String r5 = "video-bitrate"
            r4.putInt(r5, r3)
            android.media.MediaCodec r3 = r1.f423f     // Catch: java.lang.IllegalStateException -> L6d
            r3.setParameters(r4)     // Catch: java.lang.IllegalStateException -> L6d
            goto L75
        L6d:
            r3 = move-exception
            java.lang.String r1 = r1.f419a
            java.lang.String r4 = "encoder need be running"
            android.util.Log.e(r1, r4, r3)
        L75:
            java.util.concurrent.atomic.AtomicBoolean r8 = r8.f6881C
            r8.set(r2)
            goto L18
        L7b:
            w3.i r8 = w3.i.f6729a
            return r8
        */
        throw new UnsupportedOperationException("Method not decompiled: y2.e.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
