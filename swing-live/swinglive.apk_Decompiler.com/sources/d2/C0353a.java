package d2;

import I3.p;
import java.nio.ByteBuffer;

/* JADX INFO: renamed from: d2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0353a extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public B1.d f3922a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public p f3923b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public ByteBuffer f3924c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public long f3925d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public /* synthetic */ Object f3926f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ C0354b f3927m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f3928n;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0353a(C0354b c0354b, A3.c cVar) {
        super(cVar);
        this.f3927m = c0354b;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f3926f = obj;
        this.f3928n |= Integer.MIN_VALUE;
        return this.f3927m.l(null, null, this);
    }
}
