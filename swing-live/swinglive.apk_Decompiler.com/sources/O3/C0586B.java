package o3;

/* JADX INFO: renamed from: o3.B, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0586B extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f5979a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0588D f5980b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5981c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0586B(C0588D c0588d, A3.c cVar) {
        super(cVar);
        this.f5980b = c0588d;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f5979a = obj;
        this.f5981c |= Integer.MIN_VALUE;
        return this.f5980b.i(this);
    }
}
