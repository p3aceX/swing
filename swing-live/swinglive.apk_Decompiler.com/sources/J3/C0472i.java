package j3;

import java.util.Objects;

/* JADX INFO: renamed from: j3.i, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0472i {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public String f5246a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public String f5247b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public String f5248c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public String f5249d;
    public String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public String f5250f;

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj != null && C0472i.class == obj.getClass()) {
            C0472i c0472i = (C0472i) obj;
            if (Objects.equals(this.f5246a, c0472i.f5246a) && this.f5247b.equals(c0472i.f5247b) && this.f5248c.equals(c0472i.f5248c) && Objects.equals(this.f5249d, c0472i.f5249d) && Objects.equals(this.e, c0472i.e) && Objects.equals(this.f5250f, c0472i.f5250f)) {
                return true;
            }
        }
        return false;
    }

    public final int hashCode() {
        return Objects.hash(this.f5246a, this.f5247b, this.f5248c, this.f5249d, this.e, this.f5250f);
    }
}
