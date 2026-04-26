package J3;

import com.google.crypto.tink.shaded.protobuf.S;

/* JADX INFO: loaded from: classes.dex */
public abstract class h extends c implements g, N3.a, w3.a {

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final int f824m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final int f825n;

    public h(int i4, Class cls, String str, String str2, int i5) {
        this(i4, b.f816a, cls, str, str2, i5);
    }

    @Override // J3.c
    public final N3.a c() {
        s.f833a.getClass();
        return this;
    }

    public final boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (obj instanceof h) {
            h hVar = (h) obj;
            return this.f820d.equals(hVar.f820d) && this.e.equals(hVar.e) && this.f825n == hVar.f825n && this.f824m == hVar.f824m && i.a(this.f818b, hVar.f818b) && e().equals(hVar.e());
        }
        if (!(obj instanceof h)) {
            return false;
        }
        N3.a aVar = this.f817a;
        if (aVar == null) {
            c();
            this.f817a = this;
            aVar = this;
        }
        return obj.equals(aVar);
    }

    @Override // J3.g
    public final int getArity() {
        return this.f824m;
    }

    public final int hashCode() {
        e();
        return this.e.hashCode() + ((this.f820d.hashCode() + (e().hashCode() * 31)) * 31);
    }

    public final String toString() {
        N3.a aVar = this.f817a;
        if (aVar == null) {
            c();
            this.f817a = this;
            aVar = this;
        }
        if (aVar != this) {
            return aVar.toString();
        }
        String str = this.f820d;
        return "<init>".equals(str) ? "constructor (Kotlin reflection is not available)" : S.g("function ", str, " (Kotlin reflection is not available)");
    }

    public h(int i4, Object obj, Class cls, String str, String str2, int i5) {
        super(obj, cls, str, str2, (i5 & 1) == 1);
        this.f824m = i4;
        this.f825n = 0;
    }
}
