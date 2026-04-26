package e2;

import e1.AbstractC0367g;

/* JADX INFO: renamed from: e2.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0383d extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Z1.a f4096a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public AbstractC0367g f4097b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Y3.a f4098c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public g2.d f4099d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f4100f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public /* synthetic */ Object f4101m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final /* synthetic */ r f4102n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public int f4103o;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0383d(r rVar, A3.c cVar) {
        super(cVar);
        this.f4102n = rVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4101m = obj;
        this.f4103o |= Integer.MIN_VALUE;
        return this.f4102n.f(null, null, this);
    }
}
