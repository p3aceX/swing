package u1;

import com.google.crypto.tink.shaded.protobuf.S;

/* JADX INFO: renamed from: u1.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0688a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f6635a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f6636b;

    public C0688a(String str, String str2) {
        this.f6635a = str;
        if (str2 == null) {
            throw new NullPointerException("Null version");
        }
        this.f6636b = str2;
    }

    public final boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (obj instanceof C0688a) {
            C0688a c0688a = (C0688a) obj;
            if (this.f6635a.equals(c0688a.f6635a) && this.f6636b.equals(c0688a.f6636b)) {
                return true;
            }
        }
        return false;
    }

    public final int hashCode() {
        return ((this.f6635a.hashCode() ^ 1000003) * 1000003) ^ this.f6636b.hashCode();
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("LibraryVersion{libraryName=");
        sb.append(this.f6635a);
        sb.append(", version=");
        return S.h(sb, this.f6636b, "}");
    }
}
