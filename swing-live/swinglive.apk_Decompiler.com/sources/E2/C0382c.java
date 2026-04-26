package e2;

/* JADX INFO: renamed from: e2.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0382c extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f4093a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ r f4094b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4095c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0382c(r rVar, A3.c cVar) {
        super(cVar);
        this.f4094b = rVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4093a = obj;
        this.f4095c |= Integer.MIN_VALUE;
        return this.f4094b.e(null, this);
    }
}
