package d1;

import com.google.crypto.tink.shaded.protobuf.InterfaceC0318x;

/* JADX INFO: loaded from: classes.dex */
public enum X implements InterfaceC0318x {
    UNKNOWN_KEYMATERIAL(0),
    SYMMETRIC(1),
    ASYMMETRIC_PRIVATE(2),
    ASYMMETRIC_PUBLIC(3),
    REMOTE(4),
    UNRECOGNIZED(-1);


    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3908a;

    X(int i4) {
        this.f3908a = i4;
    }
}
