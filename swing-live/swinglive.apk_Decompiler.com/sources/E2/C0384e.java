package e2;

import e1.AbstractC0367g;

/* JADX INFO: renamed from: e2.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0384e extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AbstractC0367g f4104a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Y3.a f4105b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public g2.p f4106c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4107d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public /* synthetic */ Object f4108f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ r f4109m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f4110n;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0384e(r rVar, A3.c cVar) {
        super(cVar);
        this.f4109m = rVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4108f = obj;
        this.f4110n |= Integer.MIN_VALUE;
        return this.f4109m.g(null, this);
    }
}
