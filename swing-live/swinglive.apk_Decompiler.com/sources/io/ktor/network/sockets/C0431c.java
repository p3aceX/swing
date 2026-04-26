package io.ktor.network.sockets;

import io.ktor.utils.io.C0449m;
import io.ktor.utils.io.M;
import java.nio.channels.ReadableByteChannel;
import y3.InterfaceC0762c;

/* JADX INFO: renamed from: io.ktor.network.sockets.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0431c extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public io.ktor.network.util.c f4845a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public io.ktor.network.util.c f4846b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public C0449m f4847c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public ReadableByteChannel f4848d;
    public n3.q e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public n3.e f4849f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f4850m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f4851n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public int f4852o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public int f4853p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public /* synthetic */ Object f4854q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final /* synthetic */ w f4855r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final /* synthetic */ F f4856s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final /* synthetic */ C0449m f4857t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public final /* synthetic */ ReadableByteChannel f4858u;
    public final /* synthetic */ n3.e v;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0431c(w wVar, F f4, C0449m c0449m, ReadableByteChannel readableByteChannel, n3.e eVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f4855r = wVar;
        this.f4856s = f4;
        this.f4857t = c0449m;
        this.f4858u = readableByteChannel;
        this.v = eVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        ReadableByteChannel readableByteChannel = this.f4858u;
        C0431c c0431c = new C0431c(this.f4855r, this.f4856s, this.f4857t, readableByteChannel, this.v, interfaceC0762c);
        c0431c.f4854q = obj;
        return c0431c;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C0431c) create((M) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Code restructure failed: missing block: B:150:0x02ca, code lost:
    
        r9 = r15;
     */
    /* JADX WARN: Removed duplicated region for block: B:101:0x0281  */
    /* JADX WARN: Removed duplicated region for block: B:105:0x02ad  */
    /* JADX WARN: Removed duplicated region for block: B:108:0x02c1  */
    /* JADX WARN: Removed duplicated region for block: B:109:0x02c4  */
    /* JADX WARN: Removed duplicated region for block: B:114:0x02d3  */
    /* JADX WARN: Removed duplicated region for block: B:51:0x012c A[Catch: all -> 0x00b6, TryCatch #2 {all -> 0x00b6, blocks: (B:111:0x02ca, B:49:0x0126, B:51:0x012c, B:53:0x0130, B:57:0x0155, B:59:0x015e, B:61:0x0165, B:65:0x018a, B:72:0x01bf, B:75:0x01de, B:80:0x01ed, B:115:0x02d5, B:117:0x02d9, B:118:0x02dd, B:120:0x02e3, B:128:0x02fe, B:112:0x02cf, B:113:0x02d2, B:26:0x00af, B:31:0x00c9, B:34:0x00df, B:37:0x00f2, B:40:0x0101, B:43:0x010a, B:46:0x0115), top: B:141:0x0013 }] */
    /* JADX WARN: Removed duplicated region for block: B:59:0x015e A[Catch: all -> 0x00b6, TryCatch #2 {all -> 0x00b6, blocks: (B:111:0x02ca, B:49:0x0126, B:51:0x012c, B:53:0x0130, B:57:0x0155, B:59:0x015e, B:61:0x0165, B:65:0x018a, B:72:0x01bf, B:75:0x01de, B:80:0x01ed, B:115:0x02d5, B:117:0x02d9, B:118:0x02dd, B:120:0x02e3, B:128:0x02fe, B:112:0x02cf, B:113:0x02d2, B:26:0x00af, B:31:0x00c9, B:34:0x00df, B:37:0x00f2, B:40:0x0101, B:43:0x010a, B:46:0x0115), top: B:141:0x0013 }] */
    /* JADX WARN: Removed duplicated region for block: B:60:0x0163  */
    /* JADX WARN: Removed duplicated region for block: B:67:0x01b5  */
    /* JADX WARN: Removed duplicated region for block: B:68:0x01b6  */
    /* JADX WARN: Removed duplicated region for block: B:70:0x01b9  */
    /* JADX WARN: Removed duplicated region for block: B:71:0x01bb  */
    /* JADX WARN: Removed duplicated region for block: B:74:0x01dc  */
    /* JADX WARN: Removed duplicated region for block: B:78:0x01e8  */
    /* JADX WARN: Removed duplicated region for block: B:88:0x0220 A[Catch: all -> 0x009b, TryCatch #4 {all -> 0x009b, blocks: (B:86:0x0217, B:88:0x0220, B:90:0x0227, B:21:0x008c), top: B:146:0x008c }] */
    /* JADX WARN: Removed duplicated region for block: B:89:0x0225  */
    /* JADX WARN: Removed duplicated region for block: B:98:0x027d  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:105:0x02ad -> B:106:0x02b9). Please report as a decompilation issue!!! */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:77:0x01e6 -> B:79:0x01ea). Please report as a decompilation issue!!! */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:78:0x01e8 -> B:65:0x018a). Please report as a decompilation issue!!! */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r19) throws java.io.IOException {
        /*
            Method dump skipped, instruction units count: 814
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.network.sockets.C0431c.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
