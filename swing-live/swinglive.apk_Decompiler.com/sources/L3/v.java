package l3;

import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/* JADX INFO: loaded from: classes.dex */
public final class v extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public K f5728a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Set f5729b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Map f5730c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Iterator f5731d;
    public L.d e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public /* synthetic */ Object f5732f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ K f5733m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f5734n;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public v(K k4, A3.c cVar) {
        super(cVar);
        this.f5733m = k4;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f5732f = obj;
        this.f5734n |= Integer.MIN_VALUE;
        return K.s(this.f5733m, null, this);
    }
}
