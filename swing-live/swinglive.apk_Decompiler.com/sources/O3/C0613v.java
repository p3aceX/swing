package o3;

/* JADX INFO: renamed from: o3.v, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0613v extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0596d f6155a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0588D f6156b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f6157c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public /* synthetic */ Object f6158d;
    public final /* synthetic */ C0588D e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f6159f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0613v(C0588D c0588d, A3.c cVar) {
        super(cVar);
        this.e = c0588d;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f6158d = obj;
        this.f6159f |= Integer.MIN_VALUE;
        return this.e.e(this);
    }
}
