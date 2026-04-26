package io.ktor.network.sockets;

import io.ktor.utils.io.C0449m;
import io.ktor.utils.io.K;
import java.nio.channels.WritableByteChannel;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class i extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public io.ktor.network.util.c f4884a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public J3.p f4885b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public C0449m f4886c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public C0435g f4887d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f4888f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public /* synthetic */ Object f4889m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final /* synthetic */ w f4890n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final /* synthetic */ F f4891o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final /* synthetic */ C0449m f4892p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final /* synthetic */ n3.e f4893q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final /* synthetic */ WritableByteChannel f4894r;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public i(w wVar, F f4, C0449m c0449m, n3.e eVar, WritableByteChannel writableByteChannel, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f4890n = wVar;
        this.f4891o = f4;
        this.f4892p = c0449m;
        this.f4893q = eVar;
        this.f4894r = writableByteChannel;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        WritableByteChannel writableByteChannel = this.f4894r;
        i iVar = new i(this.f4890n, this.f4891o, this.f4892p, this.f4893q, writableByteChannel, interfaceC0762c);
        iVar.f4889m = obj;
        return iVar;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((i) create((K) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:50:0x00e6 A[Catch: all -> 0x0024, TryCatch #0 {all -> 0x0024, blocks: (B:10:0x0020, B:34:0x0089, B:36:0x008f, B:38:0x009a, B:41:0x00ad, B:45:0x00d0, B:47:0x00d8, B:48:0x00e2, B:50:0x00e6, B:53:0x0100, B:54:0x0131, B:56:0x0134, B:58:0x0138, B:17:0x0037, B:19:0x0042, B:22:0x0058, B:28:0x006e, B:31:0x0079), top: B:76:0x0013 }] */
    /* JADX WARN: Type inference failed for: r2v10 */
    /* JADX WARN: Type inference failed for: r2v11 */
    /* JADX WARN: Type inference failed for: r2v5, types: [I3.l] */
    /* JADX WARN: Type inference failed for: r2v7, types: [io.ktor.network.sockets.g] */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:49:0x00e4 -> B:34:0x0089). Please report as a decompilation issue!!! */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:51:0x00fd -> B:34:0x0089). Please report as a decompilation issue!!! */
    /*  JADX ERROR: JadxOverflowException in pass: RegionMakerVisitor
        jadx.core.utils.exceptions.JadxOverflowException: Regions count limit reached
        	at jadx.core.utils.ErrorsCounter.addError(ErrorsCounter.java:59)
        	at jadx.core.utils.ErrorsCounter.error(ErrorsCounter.java:31)
        	at jadx.core.dex.attributes.nodes.NotificationAttrNode.addError(NotificationAttrNode.java:19)
        */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r15) {
        /*
            Method dump skipped, instruction units count: 375
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.network.sockets.i.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
