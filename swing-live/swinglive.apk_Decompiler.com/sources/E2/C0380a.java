package e2;

import e1.AbstractC0367g;

/* JADX INFO: renamed from: e2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0380a extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AbstractC0367g f4080a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Y3.a f4081b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public g2.b f4082c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4083d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public /* synthetic */ Object f4084f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ r f4085m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f4086n;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0380a(r rVar, A3.c cVar) {
        super(cVar);
        this.f4085m = rVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4084f = obj;
        this.f4086n |= Integer.MIN_VALUE;
        return this.f4085m.a(null, this);
    }
}
