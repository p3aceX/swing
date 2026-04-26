package r2;

import java.util.Iterator;
import n2.EnumC0562e;

/* JADX INFO: loaded from: classes.dex */
public final class w extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public EnumC0562e f6416a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public J3.q f6417b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Iterator f6418c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f6419d;
    public /* synthetic */ Object e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ x f6420f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f6421m;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public w(x xVar, A3.c cVar) {
        super(cVar);
        this.f6420f = xVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.e = obj;
        this.f6421m |= Integer.MIN_VALUE;
        return this.f6420f.g(null, null, this);
    }
}
