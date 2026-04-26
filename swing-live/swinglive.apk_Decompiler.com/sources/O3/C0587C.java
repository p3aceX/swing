package o3;

/* JADX INFO: renamed from: o3.C, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0587C extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public K f5982a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f5983b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ C0588D f5984c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f5985d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0587C(C0588D c0588d, A3.c cVar) {
        super(cVar);
        this.f5984c = c0588d;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f5983b = obj;
        this.f5985d |= Integer.MIN_VALUE;
        return this.f5984c.j(null, null, this);
    }
}
