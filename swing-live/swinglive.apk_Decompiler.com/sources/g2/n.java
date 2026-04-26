package g2;

import e1.AbstractC0367g;

/* JADX INFO: loaded from: classes.dex */
public final class n extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AbstractC0367g f4392a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public byte[] f4393b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4394c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4395d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public /* synthetic */ Object f4396f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ o f4397m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f4398n;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public n(o oVar, A3.c cVar) {
        super(cVar);
        this.f4397m = oVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4396f = obj;
        this.f4398n |= Integer.MIN_VALUE;
        return this.f4397m.f(null, this);
    }
}
