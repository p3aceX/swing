package o3;

/* JADX INFO: renamed from: o3.A, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0585A extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Z3.a f5975a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f5976b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ C0588D f5977c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f5978d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0585A(C0588D c0588d, A3.c cVar) {
        super(cVar);
        this.f5977c = c0588d;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f5976b = obj;
        this.f5978d |= Integer.MIN_VALUE;
        return this.f5977c.h(this);
    }
}
