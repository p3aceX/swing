package o3;

import y3.InterfaceC0762c;

/* JADX INFO: renamed from: o3.t, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0611t extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Z3.h f6147a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0591G f6148b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f6149c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public /* synthetic */ Object f6150d;
    public final /* synthetic */ C0588D e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0611t(C0588D c0588d, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.e = c0588d;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        C0611t c0611t = new C0611t(this.e, interfaceC0762c);
        c0611t.f6150d = obj;
        return c0611t;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C0611t) create((S3.u) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Code restructure failed: missing block: B:12:0x003b, code lost:
    
        if (r14 == r1) goto L40;
     */
    /* JADX WARN: Code restructure failed: missing block: B:29:0x0092, code lost:
    
        if (r8 == o3.I.f6009o) goto L38;
     */
    /* JADX WARN: Code restructure failed: missing block: B:30:0x0094, code lost:
    
        r8 = r3.f5989d;
        J3.i.e(r8, "$v$c$io-ktor-network-tls-Digest$-$this$plusAssign$0");
        r9 = r2.f6001a;
     */
    /* JADX WARN: Code restructure failed: missing block: B:31:0x009d, code lost:
    
        if (r9 == r14) goto L36;
     */
    /* JADX WARN: Code restructure failed: missing block: B:32:0x009f, code lost:
    
        r14 = new Z3.a();
        e1.k.N(r14, r9, (int) u3.AbstractC0692a.a(r2.f6002b));
     */
    /* JADX WARN: Code restructure failed: missing block: B:33:0x00b8, code lost:
    
        if (u3.AbstractC0692a.a(r2.f6002b) <= 0) goto L35;
     */
    /* JADX WARN: Code restructure failed: missing block: B:34:0x00ba, code lost:
    
        r9 = r2.f6002b;
        J3.i.e(r9, "<this>");
        u3.AbstractC0692a.d(r14, r9.a());
     */
    /* JADX WARN: Code restructure failed: missing block: B:35:0x00c8, code lost:
    
        o3.C0596d.b(r8, r14);
     */
    /* JADX WARN: Code restructure failed: missing block: B:37:0x00d3, code lost:
    
        throw new java.lang.IllegalStateException("Check failed.");
     */
    /* JADX WARN: Code restructure failed: missing block: B:38:0x00d4, code lost:
    
        r14 = (S3.t) r0;
        r14.getClass();
        r13.f6150d = r0;
        r13.f6147a = r7;
        r13.f6148b = r2;
        r13.f6149c = 2;
     */
    /* JADX WARN: Code restructure failed: missing block: B:39:0x00e8, code lost:
    
        if (r14.f1851d.m(r2, r13) != r1) goto L41;
     */
    /* JADX WARN: Code restructure failed: missing block: B:40:0x00ea, code lost:
    
        return r1;
     */
    /* JADX WARN: Removed duplicated region for block: B:19:0x0050  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:16:0x0049 -> B:17:0x004a). Please report as a decompilation issue!!! */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:39:0x00e8 -> B:41:0x00eb). Please report as a decompilation issue!!! */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r14) throws java.lang.Exception {
        /*
            Method dump skipped, instruction units count: 288
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: o3.C0611t.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
