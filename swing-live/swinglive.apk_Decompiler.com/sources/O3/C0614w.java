package o3;

import io.ktor.utils.io.C0449m;
import y3.InterfaceC0762c;

/* JADX INFO: renamed from: o3.w, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0614w extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public S3.d f6160a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f6161b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f6162c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ C0588D f6163d;
    public final /* synthetic */ C0449m e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0614w(C0449m c0449m, C0588D c0588d, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f6163d = c0588d;
        this.e = c0449m;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        C0614w c0614w = new C0614w(this.e, this.f6163d, interfaceC0762c);
        c0614w.f6162c = obj;
        return c0614w;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C0614w) create((S3.b) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Removed duplicated region for block: B:20:0x0050  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:29:0x007c -> B:15:0x003b). Please report as a decompilation issue!!! */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r9) throws java.lang.Throwable {
        /*
            r8 = this;
            o3.D r0 = r8.f6163d
            java.lang.Object r1 = r8.f6162c
            S3.b r1 = (S3.b) r1
            z3.a r2 = z3.EnumC0789a.f6999a
            int r3 = r8.f6161b
            r4 = 2
            r5 = 1
            if (r3 == 0) goto L28
            if (r3 == r5) goto L22
            if (r3 != r4) goto L1a
            S3.d r3 = r8.f6160a
            e1.AbstractC0367g.M(r9)     // Catch: java.lang.Throwable -> L18
            goto L3b
        L18:
            r9 = move-exception
            goto L7f
        L1a:
            java.lang.IllegalStateException r9 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r9.<init>(r0)
            throw r9
        L22:
            S3.d r3 = r8.f6160a
            e1.AbstractC0367g.M(r9)
            goto L48
        L28:
            e1.AbstractC0367g.M(r9)
            r9 = r1
            S3.j r9 = (S3.j) r9
            r9.getClass()
            S3.e r9 = r9.f1851d
            r9.getClass()
            S3.d r3 = new S3.d
            r3.<init>(r9)
        L3b:
            r8.f6162c = r1
            r8.f6160a = r3
            r8.f6161b = r5
            java.lang.Object r9 = r3.b(r8)
            if (r9 != r2) goto L48
            goto L7e
        L48:
            java.lang.Boolean r9 = (java.lang.Boolean) r9
            boolean r9 = r9.booleanValue()
            if (r9 == 0) goto L87
            java.lang.Object r9 = r3.c()
            o3.K r9 = (o3.K) r9
            boolean r6 = r0.f5993o     // Catch: java.lang.Throwable -> L18
            if (r6 == 0) goto L67
            w3.f r6 = r0.f5991m     // Catch: java.lang.Throwable -> L18
            java.lang.Object r6 = r6.a()     // Catch: java.lang.Throwable -> L18
            p3.f r6 = (p3.InterfaceC0623f) r6     // Catch: java.lang.Throwable -> L18
            o3.K r6 = r6.b(r9)     // Catch: java.lang.Throwable -> L18
            goto L68
        L67:
            r6 = r9
        L68:
            o3.M r9 = r9.f6017a     // Catch: java.lang.Throwable -> L18
            o3.M r7 = o3.M.f6022d     // Catch: java.lang.Throwable -> L18
            if (r9 != r7) goto L70
            r0.f5993o = r5     // Catch: java.lang.Throwable -> L18
        L70:
            io.ktor.utils.io.m r9 = r8.e     // Catch: java.lang.Throwable -> L18
            r8.f6162c = r1     // Catch: java.lang.Throwable -> L18
            r8.f6160a = r3     // Catch: java.lang.Throwable -> L18
            r8.f6161b = r4     // Catch: java.lang.Throwable -> L18
            java.lang.Object r9 = e1.k.M(r9, r6, r8)     // Catch: java.lang.Throwable -> L18
            if (r9 != r2) goto L3b
        L7e:
            return r2
        L7f:
            S3.j r1 = (S3.j) r1
            r1.getClass()
            r1.j(r9)
        L87:
            w3.i r9 = w3.i.f6729a
            return r9
        */
        throw new UnsupportedOperationException("Method not decompiled: o3.C0614w.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
