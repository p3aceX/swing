package d2;

import I3.p;
import b2.C0246b;
import java.nio.ByteBuffer;

/* JADX INFO: renamed from: d2.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0356d extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public B1.d f3933a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public p f3934b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public ByteBuffer f3935c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public long f3936d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public /* synthetic */ Object f3937f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ C0246b f3938m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f3939n;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0356d(C0246b c0246b, A3.c cVar) {
        super(cVar);
        this.f3938m = c0246b;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f3937f = obj;
        this.f3939n |= Integer.MIN_VALUE;
        return this.f3938m.l(null, null, this);
    }
}
