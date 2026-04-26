package y1;

/* JADX INFO: renamed from: y1.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0753c extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f6839a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0754d f6840b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f6841c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0753c(C0754d c0754d, A3.c cVar) {
        super(cVar);
        this.f6840b = c0754d;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f6839a = obj;
        this.f6841c |= Integer.MIN_VALUE;
        return this.f6840b.a(0L, this);
    }
}
