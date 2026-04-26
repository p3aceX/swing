package I;

import java.io.FileInputStream;

/* JADX INFO: loaded from: classes.dex */
public final class S extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Object f608a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public FileInputStream f609b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f610c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ T f611d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public S(T t4, A3.c cVar) {
        super(cVar);
        this.f611d = t4;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f610c = obj;
        this.e |= Integer.MIN_VALUE;
        return T.a(this.f611d, this);
    }
}
