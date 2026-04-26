package e2;

import e1.AbstractC0367g;

/* JADX INFO: renamed from: e2.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0381b extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AbstractC0367g f4087a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Y3.a f4088b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4089c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4090d;
    public /* synthetic */ Object e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ r f4091f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f4092m;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0381b(r rVar, A3.c cVar) {
        super(cVar);
        this.f4091f = rVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.e = obj;
        this.f4092m |= Integer.MIN_VALUE;
        return this.f4091f.b(null, this);
    }
}
