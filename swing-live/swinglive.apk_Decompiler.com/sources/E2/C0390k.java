package e2;

import e1.AbstractC0367g;

/* JADX INFO: renamed from: e2.k, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0390k extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Z1.a f4144a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public AbstractC0367g f4145b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Y3.a f4146c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public g2.d f4147d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f4148f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public /* synthetic */ Object f4149m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final /* synthetic */ r f4150n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public int f4151o;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0390k(r rVar, A3.c cVar) {
        super(cVar);
        this.f4150n = rVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4149m = obj;
        this.f4151o |= Integer.MIN_VALUE;
        return this.f4150n.q(null, null, this);
    }
}
