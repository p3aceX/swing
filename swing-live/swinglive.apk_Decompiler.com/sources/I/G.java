package I;

import java.io.Serializable;

/* JADX INFO: loaded from: classes.dex */
public final class G extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Object f555a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f556b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Serializable f557c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public J3.r f558d;
    public boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f559f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public /* synthetic */ Object f560m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final /* synthetic */ Q f561n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public int f562o;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public G(Q q4, A3.c cVar) {
        super(cVar);
        this.f561n = q4;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f560m = obj;
        this.f562o |= Integer.MIN_VALUE;
        return Q.e(this.f561n, false, this);
    }
}
