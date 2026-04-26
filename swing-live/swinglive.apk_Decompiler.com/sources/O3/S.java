package o3;

import java.nio.ByteBuffer;
import v3.InterfaceC0697c;

/* JADX INFO: loaded from: classes.dex */
public final class S extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public io.ktor.utils.io.o f6044a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public InterfaceC0697c f6045b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Object f6046c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public ByteBuffer f6047d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f6048f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public /* synthetic */ Object f6049m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final /* synthetic */ V f6050n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public int f6051o;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public S(V v, A3.c cVar) {
        super(cVar);
        this.f6050n = v;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f6049m = obj;
        this.f6051o |= Integer.MIN_VALUE;
        return V.d(this.f6050n, null, this);
    }
}
