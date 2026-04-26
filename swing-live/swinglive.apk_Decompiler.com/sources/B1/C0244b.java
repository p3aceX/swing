package b1;

import R0.f;
import java.util.Objects;

/* JADX INFO: renamed from: b1.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0244b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final f f3271a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f3272b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f3273c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f3274d;

    public C0244b(f fVar, int i4, String str, String str2) {
        this.f3271a = fVar;
        this.f3272b = i4;
        this.f3273c = str;
        this.f3274d = str2;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof C0244b)) {
            return false;
        }
        C0244b c0244b = (C0244b) obj;
        return this.f3271a == c0244b.f3271a && this.f3272b == c0244b.f3272b && this.f3273c.equals(c0244b.f3273c) && this.f3274d.equals(c0244b.f3274d);
    }

    public final int hashCode() {
        return Objects.hash(this.f3271a, Integer.valueOf(this.f3272b), this.f3273c, this.f3274d);
    }

    public final String toString() {
        return "(status=" + this.f3271a + ", keyId=" + this.f3272b + ", keyType='" + this.f3273c + "', keyPrefix='" + this.f3274d + "')";
    }
}
