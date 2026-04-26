package e2;

import e1.AbstractC0367g;

/* JADX INFO: renamed from: e2.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0385f extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AbstractC0367g f4111a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Y3.a f4112b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4113c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4114d;
    public /* synthetic */ Object e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ r f4115f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f4116m;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0385f(r rVar, A3.c cVar) {
        super(cVar);
        this.f4115f = rVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.e = obj;
        this.f4116m |= Integer.MIN_VALUE;
        return this.f4115f.h(null, this);
    }
}
