package e2;

import e1.AbstractC0367g;

/* JADX INFO: renamed from: e2.J, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0378J extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AbstractC0367g f4038a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public g2.o f4039b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public String f4040c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public String f4041d;
    public /* synthetic */ Object e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ L f4042f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f4043m;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0378J(L l2, A3.c cVar) {
        super(cVar);
        this.f4042f = l2;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.e = obj;
        this.f4043m |= Integer.MIN_VALUE;
        return this.f4042f.e(this);
    }
}
