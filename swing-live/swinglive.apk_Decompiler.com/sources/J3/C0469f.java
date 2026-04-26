package j3;

import java.util.List;
import java.util.Objects;

/* JADX INFO: renamed from: j3.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0469f {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public List f5237a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public EnumC0471h f5238b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public String f5239c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public String f5240d;
    public String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public Boolean f5241f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public String f5242g;

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj != null && C0469f.class == obj.getClass()) {
            C0469f c0469f = (C0469f) obj;
            if (this.f5237a.equals(c0469f.f5237a) && this.f5238b.equals(c0469f.f5238b) && Objects.equals(this.f5239c, c0469f.f5239c) && Objects.equals(this.f5240d, c0469f.f5240d) && Objects.equals(this.e, c0469f.e) && this.f5241f.equals(c0469f.f5241f) && Objects.equals(this.f5242g, c0469f.f5242g)) {
                return true;
            }
        }
        return false;
    }

    public final int hashCode() {
        return Objects.hash(this.f5237a, this.f5238b, this.f5239c, this.f5240d, this.e, this.f5241f, this.f5242g);
    }
}
