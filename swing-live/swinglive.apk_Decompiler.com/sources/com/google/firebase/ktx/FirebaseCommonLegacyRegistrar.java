package com.google.firebase.ktx;

import androidx.annotation.Keep;
import com.google.firebase.components.ComponentRegistrar;
import e1.AbstractC0367g;
import e1.k;
import java.util.List;
import l1.C0522a;

/* JADX INFO: loaded from: classes.dex */
@Keep
public final class FirebaseCommonLegacyRegistrar implements ComponentRegistrar {
    @Override // com.google.firebase.components.ComponentRegistrar
    public List<C0522a> getComponents() {
        return k.x(AbstractC0367g.g("fire-core-ktx", "20.4.2"));
    }
}
