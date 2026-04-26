package d1;

import com.google.crypto.tink.shaded.protobuf.InterfaceC0318x;

/* JADX INFO: loaded from: classes.dex */
public enum Z implements InterfaceC0318x {
    UNKNOWN_STATUS(0),
    ENABLED(1),
    DISABLED(2),
    DESTROYED(3),
    UNRECOGNIZED(-1);


    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3914a;

    Z(int i4) {
        this.f3914a = i4;
    }

    public final int a() {
        if (this != UNRECOGNIZED) {
            return this.f3914a;
        }
        throw new IllegalArgumentException("Can't get the number of an unknown enum value.");
    }
}
