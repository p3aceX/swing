package io.ktor.utils.io;

import Q3.C0136j0;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class y extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0136j0 f5025a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Throwable f5026b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5027c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public /* synthetic */ Object f5028d;
    public final /* synthetic */ A3.j e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ C0449m f5029f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    /* JADX WARN: Multi-variable type inference failed */
    public y(I3.p pVar, C0449m c0449m, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.e = (A3.j) pVar;
        this.f5029f = c0449m;
    }

    /* JADX WARN: Type inference failed for: r1v0, types: [A3.j, I3.p] */
    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        y yVar = new y(this.e, this.f5029f, interfaceC0762c);
        yVar.f5028d = obj;
        return yVar;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((y) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Code restructure failed: missing block: B:38:0x00b8, code lost:
    
        if (r3.i(r8) != r1) goto L59;
     */
    /* JADX WARN: Code restructure failed: missing block: B:46:0x00ea, code lost:
    
        if (r3.i(r8) != r1) goto L59;
     */
    /* JADX WARN: Code restructure failed: missing block: B:55:0x010d, code lost:
    
        if (r3.i(r8) != r1) goto L65;
     */
    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:33:0x008e A[Catch: all -> 0x004d, TRY_LEAVE, TryCatch #1 {all -> 0x004d, blocks: (B:23:0x0049, B:31:0x007d, B:33:0x008e, B:28:0x005f), top: B:60:0x000d }] */
    /* JADX WARN: Removed duplicated region for block: B:37:0x00ab A[Catch: all -> 0x0040, TRY_ENTER, TRY_LEAVE, TryCatch #0 {all -> 0x0040, blocks: (B:13:0x002d, B:45:0x00dd, B:17:0x003b, B:37:0x00ab), top: B:60:0x000d }] */
    /* JADX WARN: Type inference failed for: r0v1, types: [Q3.D, java.lang.Object] */
    /* JADX WARN: Type inference failed for: r0v14 */
    /* JADX WARN: Type inference failed for: r0v15 */
    /* JADX WARN: Type inference failed for: r0v2, types: [java.lang.Throwable] */
    /* JADX WARN: Type inference failed for: r0v7, types: [java.lang.Throwable] */
    /* JADX WARN: Type inference failed for: r2v0, types: [int] */
    /* JADX WARN: Type inference failed for: r2v1, types: [Q3.q0] */
    /* JADX WARN: Type inference failed for: r2v3, types: [Q3.q0] */
    /* JADX WARN: Type inference failed for: r2v5 */
    /* JADX WARN: Type inference failed for: r2v6 */
    /* JADX WARN: Type inference failed for: r9v13, types: [A3.j, I3.p] */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r9) {
        /*
            Method dump skipped, instruction units count: 296
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.utils.io.y.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
