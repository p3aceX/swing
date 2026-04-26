package io.ktor.network.sockets;

import io.ktor.utils.io.C0449m;
import io.ktor.utils.io.M;
import java.nio.ByteBuffer;
import java.nio.channels.ReadableByteChannel;
import v3.C0695a;
import y3.InterfaceC0762c;

/* JADX INFO: renamed from: io.ktor.network.sockets.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0433e extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public io.ktor.network.util.c f4860a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public J3.p f4861b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public io.ktor.network.util.c f4862c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public ReadableByteChannel f4863d;
    public ByteBuffer e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public C0449m f4864f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public n3.q f4865m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public n3.e f4866n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public int f4867o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public int f4868p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public int f4869q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public /* synthetic */ Object f4870r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final /* synthetic */ F f4871s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final /* synthetic */ C0449m f4872t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public final /* synthetic */ w f4873u;
    public final /* synthetic */ ByteBuffer v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public final /* synthetic */ C0695a f4874w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public final /* synthetic */ ReadableByteChannel f4875x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public final /* synthetic */ n3.e f4876y;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0433e(F f4, C0449m c0449m, w wVar, ByteBuffer byteBuffer, C0695a c0695a, ReadableByteChannel readableByteChannel, n3.e eVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f4871s = f4;
        this.f4872t = c0449m;
        this.f4873u = wVar;
        this.v = byteBuffer;
        this.f4874w = c0695a;
        this.f4875x = readableByteChannel;
        this.f4876y = eVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        ReadableByteChannel readableByteChannel = this.f4875x;
        C0433e c0433e = new C0433e(this.f4871s, this.f4872t, this.f4873u, this.v, this.f4874w, readableByteChannel, this.f4876y, interfaceC0762c);
        c0433e.f4870r = obj;
        return c0433e;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C0433e) create((M) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Code restructure failed: missing block: B:106:0x027b, code lost:
    
        if (r12 == r2) goto L107;
     */
    /* JADX WARN: Code restructure failed: missing block: B:144:0x027e, code lost:
    
        if (r4 != r2) goto L132;
     */
    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Path cross not found for [B:105:0x027a, B:106:0x027b], limit reached: 143 */
    /* JADX WARN: Removed duplicated region for block: B:102:0x0246  */
    /* JADX WARN: Removed duplicated region for block: B:112:0x0288  */
    /* JADX WARN: Removed duplicated region for block: B:125:0x0205 A[EXC_TOP_SPLITTER, SYNTHETIC] */
    /* JADX WARN: Removed duplicated region for block: B:139:0x029e A[EXC_TOP_SPLITTER, SYNTHETIC] */
    /* JADX WARN: Removed duplicated region for block: B:39:0x00eb  */
    /* JADX WARN: Removed duplicated region for block: B:42:0x00fb A[Catch: all -> 0x0033, TryCatch #1 {all -> 0x0033, blocks: (B:10:0x0027, B:37:0x00e2, B:40:0x00f3, B:42:0x00fb, B:46:0x012c, B:51:0x016b, B:55:0x0178, B:25:0x009d, B:28:0x00b9, B:32:0x00c7, B:35:0x00d2), top: B:127:0x0019 }] */
    /* JADX WARN: Removed duplicated region for block: B:48:0x0156  */
    /* JADX WARN: Removed duplicated region for block: B:50:0x0168  */
    /* JADX WARN: Removed duplicated region for block: B:53:0x016f  */
    /* JADX WARN: Removed duplicated region for block: B:54:0x0174  */
    /* JADX WARN: Removed duplicated region for block: B:55:0x0178 A[Catch: all -> 0x0033, TRY_LEAVE, TryCatch #1 {all -> 0x0033, blocks: (B:10:0x0027, B:37:0x00e2, B:40:0x00f3, B:42:0x00fb, B:46:0x012c, B:51:0x016b, B:55:0x0178, B:25:0x009d, B:28:0x00b9, B:32:0x00c7, B:35:0x00d2), top: B:127:0x0019 }] */
    /* JADX WARN: Removed duplicated region for block: B:59:0x0191  */
    /* JADX WARN: Removed duplicated region for block: B:68:0x01e4  */
    /* JADX WARN: Removed duplicated region for block: B:69:0x01e6  */
    /* JADX WARN: Removed duplicated region for block: B:76:0x01fe  */
    /* JADX WARN: Removed duplicated region for block: B:83:0x020f A[Catch: all -> 0x0241, TRY_ENTER, TRY_LEAVE, TryCatch #0 {all -> 0x0241, blocks: (B:80:0x0208, B:83:0x020f, B:79:0x0205), top: B:125:0x0205 }] */
    /* JADX WARN: Type inference failed for: r14v0 */
    /* JADX WARN: Type inference failed for: r14v1 */
    /* JADX WARN: Type inference failed for: r14v14 */
    /* JADX WARN: Type inference failed for: r14v20 */
    /* JADX WARN: Type inference failed for: r14v23 */
    /* JADX WARN: Type inference failed for: r14v24 */
    /* JADX WARN: Type inference failed for: r14v27 */
    /* JADX WARN: Type inference failed for: r14v28 */
    /* JADX WARN: Type inference failed for: r14v3 */
    /* JADX WARN: Type inference failed for: r14v5 */
    /* JADX WARN: Type inference failed for: r14v7, types: [io.ktor.network.util.c] */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:112:0x0288 -> B:57:0x0189). Please report as a decompilation issue!!! */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:54:0x0174 -> B:40:0x00f3). Please report as a decompilation issue!!! */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r24) throws java.lang.Throwable {
        /*
            Method dump skipped, instruction units count: 692
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.network.sockets.C0433e.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
