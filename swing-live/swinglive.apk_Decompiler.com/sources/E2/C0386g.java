package e2;

import e1.AbstractC0367g;

/* JADX INFO: renamed from: e2.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0386g extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public String f4117a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public AbstractC0367g f4118b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Y3.a f4119c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4120d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public /* synthetic */ Object f4121f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ r f4122m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f4123n;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0386g(r rVar, A3.c cVar) {
        super(cVar);
        this.f4122m = rVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4121f = obj;
        this.f4123n |= Integer.MIN_VALUE;
        return this.f4122m.j(null, null, this);
    }
}
