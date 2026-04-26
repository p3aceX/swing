package m;

import java.util.HashMap;

/* JADX INFO: renamed from: m.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0539a extends C0544f {
    public final HashMap e = new HashMap();

    @Override // m.C0544f
    public final C0541c f(Object obj) {
        return (C0541c) this.e.get(obj);
    }

    @Override // m.C0544f
    public final Object g(Object obj) {
        Object objG = super.g(obj);
        this.e.remove(obj);
        return objG;
    }
}
