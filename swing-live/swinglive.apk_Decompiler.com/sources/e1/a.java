package E1;

/* JADX INFO: loaded from: classes.dex */
public final class a extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public long f303a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f304b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ b f305c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f306d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public a(b bVar, A3.c cVar) {
        super(cVar);
        this.f305c = bVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f304b = obj;
        this.f306d |= Integer.MIN_VALUE;
        return this.f305c.m(0L, this);
    }
}
