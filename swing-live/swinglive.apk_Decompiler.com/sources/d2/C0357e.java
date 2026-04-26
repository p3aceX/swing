package d2;

import I3.p;
import java.nio.ByteBuffer;

/* JADX INFO: renamed from: d2.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0357e extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public B1.d f3940a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public p f3941b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public ByteBuffer f3942c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public long f3943d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f3944f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f3945m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public /* synthetic */ Object f3946n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final /* synthetic */ C0358f f3947o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public int f3948p;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0357e(C0358f c0358f, A3.c cVar) {
        super(cVar);
        this.f3947o = c0358f;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f3946n = obj;
        this.f3948p |= Integer.MIN_VALUE;
        return this.f3947o.l(null, null, this);
    }
}
