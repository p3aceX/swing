package o3;

import io.ktor.utils.io.C0449m;
import y3.InterfaceC0762c;

/* JADX INFO: renamed from: o3.u, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0612u extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f6151a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f6152b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f6153c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ C0449m f6154d;
    public final /* synthetic */ C0588D e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0612u(C0449m c0449m, C0588D c0588d, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f6154d = c0449m;
        this.e = c0588d;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        C0612u c0612u = new C0612u(this.f6154d, this.e, interfaceC0762c);
        c0612u.f6153c = obj;
        return c0612u;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C0612u) create((S3.u) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Code restructure failed: missing block: B:30:0x0077, code lost:
    
        if (r10.f1851d.m(r11, r13) == r1) goto L31;
     */
    /* JADX WARN: Removed duplicated region for block: B:19:0x0040  */
    /* JADX WARN: Removed duplicated region for block: B:20:0x0041  */
    /* JADX WARN: Removed duplicated region for block: B:23:0x0048 A[Catch: all -> 0x001d, o -> 0x0136, TryCatch #1 {all -> 0x001d, blocks: (B:7:0x0018, B:17:0x0032, B:21:0x0044, B:23:0x0048, B:24:0x0054, B:26:0x0058, B:29:0x0060, B:32:0x007a, B:36:0x0089, B:39:0x0091, B:43:0x00a0, B:46:0x00a8, B:50:0x00b2, B:53:0x00df, B:54:0x00ea, B:55:0x00eb, B:56:0x00f6, B:58:0x00f9, B:61:0x0102, B:62:0x011d, B:63:0x011e, B:64:0x0125, B:14:0x002a), top: B:74:0x0010, outer: #0 }] */
    /* JADX WARN: Removed duplicated region for block: B:28:0x005e  */
    /* JADX WARN: Removed duplicated region for block: B:57:0x00f7  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:30:0x0077 -> B:8:0x001b). Please report as a decompilation issue!!! */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:60:0x00ff -> B:17:0x0032). Please report as a decompilation issue!!! */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r14) {
        /*
            Method dump skipped, instruction units count: 326
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: o3.C0612u.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
