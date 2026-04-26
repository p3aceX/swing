package M3;

/* JADX INFO: loaded from: classes.dex */
public final class c extends a {
    static {
        new c((char) 1, (char) 0);
    }

    public final boolean equals(Object obj) {
        c cVar;
        char c5;
        char c6;
        if (!(obj instanceof c)) {
            return false;
        }
        char c7 = this.f1088a;
        char c8 = this.f1089b;
        if (c7 >= c8 && c7 != c8 && (c5 = (cVar = (c) obj).f1088a) >= (c6 = cVar.f1089b) && c5 != c6) {
            return true;
        }
        c cVar2 = (c) obj;
        return c7 == cVar2.f1088a && c8 == cVar2.f1089b;
    }

    public final int hashCode() {
        char c5 = this.f1088a;
        char c6 = this.f1089b;
        if (c5 >= c6 && c5 != c6) {
            return -1;
        }
        return (c5 * 31) + c6;
    }

    public final String toString() {
        return this.f1088a + ".." + this.f1089b;
    }
}
