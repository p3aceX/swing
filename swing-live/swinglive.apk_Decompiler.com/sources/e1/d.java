package E1;

/* JADX INFO: loaded from: classes.dex */
public final class d extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public b f319a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f320b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ b f321c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f322d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public d(b bVar, A3.c cVar) {
        super(cVar);
        this.f321c = bVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f320b = obj;
        this.f322d |= Integer.MIN_VALUE;
        return b.l(this.f321c, this);
    }
}
