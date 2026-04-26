package g2;

import X.N;
import e1.AbstractC0367g;
import f2.EnumC0402b;

/* JADX INFO: loaded from: classes.dex */
public final class e extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AbstractC0367g f4328a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public EnumC0402b f4329b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4330c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4331d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f4332f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public /* synthetic */ Object f4333m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final /* synthetic */ N f4334n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public int f4335o;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public e(N n4, A3.c cVar) {
        super(cVar);
        this.f4334n = n4;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4333m = obj;
        this.f4335o |= Integer.MIN_VALUE;
        return this.f4334n.k(null, this);
    }
}
