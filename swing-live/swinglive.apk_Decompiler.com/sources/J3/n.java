package J3;

import com.google.crypto.tink.shaded.protobuf.S;

/* JADX INFO: loaded from: classes.dex */
public abstract class n extends c implements N3.d {

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final boolean f828m;

    public n(Object obj, Class cls, String str, String str2, int i4) {
        super(obj, cls, str, str2, (i4 & 1) == 1);
        this.f828m = false;
    }

    public final boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (obj instanceof n) {
            n nVar = (n) obj;
            return e().equals(nVar.e()) && this.f820d.equals(nVar.f820d) && this.e.equals(nVar.e) && i.a(this.f818b, nVar.f818b);
        }
        if (obj instanceof N3.d) {
            return obj.equals(f());
        }
        return false;
    }

    public final N3.a f() {
        if (this.f828m) {
            return this;
        }
        N3.a aVar = this.f817a;
        if (aVar != null) {
            return aVar;
        }
        N3.a aVarC = c();
        this.f817a = aVarC;
        return aVarC;
    }

    public final int hashCode() {
        return this.e.hashCode() + ((this.f820d.hashCode() + (e().hashCode() * 31)) * 31);
    }

    public final String toString() {
        N3.a aVarF = f();
        return aVarF != this ? aVarF.toString() : S.h(new StringBuilder("property "), this.f820d, " (Kotlin reflection is not available)");
    }
}
